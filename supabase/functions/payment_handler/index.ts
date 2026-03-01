import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.3'

// --- PENGAMAN CORS (BIAR NGGAK DIBLOKIR FLUTTER WEB/EMULATOR) ---
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// 1. KONFIGURASI KEY
const midtransServerKey = "Mid-server-2kXnWuX6LBIPKLehKDrGn5zB" 
const supabaseUrl = "https://qwpubtwhjogiwelonorv.supabase.co"
const supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF3cHVidHdoam9naXdlbG9ub3J2Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MTg1OTI1MiwiZXhwIjoyMDg3NDM1MjUyfQ.ATIAATAdPe6Iy2xaSrvRRfHV6ur057BUPO3eBpLuXrI" 

Deno.serve(async (req) => {
  // Handle CORS Preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  const supabase = createClient(supabaseUrl, supabaseKey)
  const url = new URL(req.url)

  // ====================================================================
  // FITUR A: TERIMA WEBHOOK DARI MIDTRANS (Jalur: /payment_handler/webhook)
  // ====================================================================
  if (req.method === 'POST' && url.pathname.endsWith('webhook')) {
    try {
      const body = await req.json()
      const orderId = body.order_id
      const txStatus = body.transaction_status

      console.log(`Webhook diterima untuk Order: ${orderId}, Status: ${txStatus}`)

      if (txStatus === 'settlement' || txStatus === 'capture') {
          // Update status ke sukses
          await supabase.from('donasi_qris').update({ status: 'success' }).eq('order_id', orderId)
      } else if (['cancel', 'expire', 'deny'].includes(txStatus)) {
          // Update status ke gagal
          await supabase.from('donasi_qris').update({ status: 'gagal' }).eq('order_id', orderId)
      }
      
      return new Response(JSON.stringify({ status: 'ok', message: 'Webhook processed' }), { 
        headers: { ...corsHeaders, "Content-Type": "application/json" } 
      })
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : String(err)
      console.error("Webhook Error:", errorMessage)
      return new Response(JSON.stringify({ error: "Error processing webhook" }), { 
        status: 500, headers: corsHeaders 
      })
    }
  }

  // ====================================================================
  // FITUR B: BIKIN TRANSAKSI QRIS BARU DARI FLUTTER
  // ====================================================================
  if (req.method === 'POST') {
      try {
        const { nama, jumlah, judulBerita, beritaId, userId } = await req.json()
        
        // Buat ID unik untuk transaksi
        const orderId = "DONASI-" + Date.now() 

        // Panggil API Midtrans
        const mRes = await fetch("https://api.sandbox.midtrans.com/v2/charge", {
            method: "POST",
            headers: {
              "Accept": "application/json", 
              "Content-Type": "application/json",
              "Authorization": "Basic " + btoa(midtransServerKey + ":")
            },
            body: JSON.stringify({
                payment_type: "qris",
                transaction_details: { 
                  order_id: orderId, 
                  gross_amount: jumlah 
                },
                customer_details: { 
                  first_name: nama 
                }
            })
        })

        const mData = await mRes.json()

        // Validasi respon Midtrans
        if (!mRes.ok || !mData.actions || mData.actions.length === 0) {
            return new Response(JSON.stringify({ 
              error: "Gagal mendapatkan QRIS dari Midtrans", 
              detail: mData 
            }), { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } })
        }

        const qrisUrl = mData.actions[0].url 
        
        // Simpan ke database donasi_qris
        const { error: dbError } = await supabase.from('donasi_qris').insert([{ 
          order_id: orderId, 
          nama_donatur: nama, 
          jumlah: jumlah, 
          status: 'pending', 
          qris_url: qrisUrl,
          judul_berita: judulBerita, 
          berita_id: beritaId,
          user_id: userId || null
        }])

        if (dbError) throw dbError

        // Kirim balik ke Flutter
        return new Response(JSON.stringify({ 
          qris_url: qrisUrl, 
          order_id: orderId 
        }), { headers: { ...corsHeaders, "Content-Type": "application/json" } })
      
      } catch (err) {
        const errorMessage = err instanceof Error ? err.message : String(err)
        console.error("Server Error:", errorMessage)
        return new Response(JSON.stringify({ error: errorMessage }), { 
          status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } 
        })
      }
  }

  return new Response("Method not allowed.", { status: 405, headers: corsHeaders })
})