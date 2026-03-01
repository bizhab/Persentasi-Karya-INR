import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.3'

// --- PENGAMAN CORS (BIAR NGGAK DIBLOKIR FLUTTER WEB/EMULATOR) ---
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// 1. GANTI PAKE SERVER KEY SANDBOX MIDTRANS KAMU
// 1. GANTI PAKE SERVER KEY SANDBOX MIDTRANS KAMU
const midtransServerKey = "Mid-server-2kXnWuX6LBIPKLehKDrGn5zB" 

// 2. URL SUPABASE KAMU (Udah bener)
const supabaseUrl = "https://qwpubtwhjogiwelonorv.supabase.co"

// 3. GANTI PAKE SERVICE ROLE KEY SUPABASE KAMU
// Cara ambilnya: Buka web Supabase -> Project Settings -> API -> Project Secrets -> service_role (Reveal & Copy)
const supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF3cHVidHdoam9naXdlbG9ub3J2Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MTg1OTI1MiwiZXhwIjoyMDg3NDM1MjUyfQ.ATIAATAdPe6Iy2xaSrvRRfHV6ur057BUPO3eBpLuXrI" 

Deno.serve(async (req) => {
  // JAWABAN BASA-BASI CORS BUAT BROWSER
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  const supabase = createClient(supabaseUrl, supabaseKey)
  
  // ====================================================================
  // FITUR A: TERIMA WEBHOOK DARI MIDTRANS
  // ====================================================================
  if (req.method === 'POST' && req.url.includes('webhook')) {
    try {
      const body = await req.json()
      const orderId = body.order_id
      const txStatus = body.transaction_status

      if(txStatus === 'settlement' || txStatus === 'capture'){
          await supabase.from('donasi_qris').update({ status: 'success' }).eq('order_id', orderId)
      } else if (txStatus === 'cancel' || txStatus === 'expire' || txStatus === 'deny') {
          await supabase.from('donasi_qris').update({ status: 'gagal' }).eq('order_id', orderId)
      }
      
      return new Response(JSON.stringify({ status: 'ok' }), { headers: { ...corsHeaders, "Content-Type": "application/json" } })
    } catch (err) {
      return new Response("Error processing webhook", { status: 500, headers: corsHeaders })
    }
  }

  // ====================================================================
  // FITUR B: BIKIN TRANSAKSI QRIS BARU DARI FLUTTER
  // ====================================================================
  if(req.method === 'POST'){
      try {
        const { nama, jumlah, judulBerita, beritaId, userId } = await req.json()
        const orderId = "DONASI-" + new Date().getTime() 

        const mRes = await fetch("https://api.sandbox.midtrans.com/v2/charge", {
            method: "POST",
            headers: {
              "Accept": "application/json", 
              "Content-Type": "application/json",
              "Authorization": "Basic " + btoa(midtransServerKey + ":")
            },
            body: JSON.stringify({
                payment_type: "qris",
                transaction_details: { order_id: orderId, gross_amount: jumlah },
                customer_details: { first_name: nama }
            })
        })

        const mData = await mRes.json()

        if (!mData.actions || mData.actions.length === 0) {
            return new Response(JSON.stringify({ error: "Gagal dapet QRIS", detail: mData }), { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } })
        }

        const qrisUrl = mData.actions[0].url 
        
        let dataInsert: any = { 
          order_id: orderId, nama_donatur: nama, jumlah: jumlah, 
          status: 'pending', qris_url: qrisUrl,
          judul_berita: judulBerita, berita_id: beritaId
        }
        if(userId) dataInsert['user_id'] = userId;

        await supabase.from('donasi_qris').insert([dataInsert])

        // BALIKIN DATA KE FLUTTER DENGAN IZIN CORS
        return new Response(JSON.stringify({ qris_url: qrisUrl, order_id: orderId }), { headers: { ...corsHeaders, "Content-Type": "application/json" } })
      
      } catch (err: any) {
        return new Response(JSON.stringify({ error: err.message }), { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } })
      }
  }

  return new Response("Method not allowed.", { status: 405, headers: corsHeaders })
})