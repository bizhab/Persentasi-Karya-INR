import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.3'

// 1. GANTI PAKE SERVER KEY SANDBOX MIDTRANS KAMU
const midtransServerKey = "Mid-server-2kXnWuX6LBIPKLehKDrGn5zB" 

// 2. URL SUPABASE KAMU (Udah bener)
const supabaseUrl = "https://qwpubtwhjogiwelonorv.supabase.co"

// 3. GANTI PAKE SERVICE ROLE KEY SUPABASE KAMU
// Cara ambilnya: Buka web Supabase -> Project Settings -> API -> Project Secrets -> service_role (Reveal & Copy)
const supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF3cHVidHdoam9naXdlbG9ub3J2Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MTg1OTI1MiwiZXhwIjoyMDg3NDM1MjUyfQ.ATIAATAdPe6Iy2xaSrvRRfHV6ur057BUPO3eBpLuXrI" 

Deno.serve(async (req) => {
  const supabase = createClient(supabaseUrl, supabaseKey)
  
  // ====================================================================
  // FITUR A: TERIMA WEB  HOOK DARI MIDTRANS (UPDATE DATABASE OTOMATIS)
  // ====================================================================
  if (req.method === 'POST' && req.url.includes('webhook')) {
    try {
      const body = await req.json()
      const orderId = body.order_id
      const txStatus = body.transaction_status

      // Kalau lunas
      if(txStatus === 'settlement' || txStatus === 'capture'){
          await supabase.from('donasi_qris').update({ status: 'success' }).eq('order_id', orderId)
      } 
      // Kalau batal / kadaluarsa
      else if (txStatus === 'cancel' || txStatus === 'expire' || txStatus === 'deny') {
          await supabase.from('donasi_qris').update({ status: 'gagal' }).eq('order_id', orderId)
      }
      
      // Kasih jempol ke Midtrans biar dia ga ngirim notif berulang-ulang
      return new Response(JSON.stringify({ status: 'ok' }), { headers: { "Content-Type": "application/json" } })
    } catch (_err) {
      return new Response("Error processing webhook", { status: 500 })
    }
  }

  // ====================================================================
  // FITUR B: BIKIN TRANSAKSI QRIS BARU (DIPANGGIL DARI FLUTTER)
  // ====================================================================
  if(req.method === 'POST'){
      try {
        const { nama, jumlah, judulBerita, beritaId, userId } = await req.json()
        const orderId = "DONASI-" + new Date().getTime() 

        // Nembak API Midtrans pake Base64 Auth
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

        // Jaga-jaga kalau Midtrans lagi error
        if (!mData.actions || mData.actions.length === 0) {
            return new Response(JSON.stringify({ error: "Gagal dapet QRIS dari Midtrans", detail: mData }), { status: 400, headers: { "Content-Type": "application/json" } })
        }

        const qrisUrl = mData.actions[0].url 
        
        // Siapin data buat dimasukin ke Supabase
        let dataInsert: any = { 
          order_id: orderId, 
          nama_donatur: nama, 
          jumlah: jumlah, 
          status: 'pending', 
          qris_url: qrisUrl,
          judul_berita: judulBerita, 
          berita_id: beritaId
        }
        
        // Kalau user-nya lagi login, tempelin ID-nya
        if(userId) {
           dataInsert['user_id'] = userId;
        }

        // Insert ke tabel donasi_qris
        await supabase.from('donasi_qris').insert([dataInsert])

        // Balikin URL QRIS-nya ke Flutter biar ditampilin di layar
        return new Response(JSON.stringify({ qris_url: qrisUrl, order_id: orderId }), { headers: { "Content-Type": "application/json" } })
      
      } catch (err) {
        const errorMessage = err instanceof Error ? err.message : String(err)
        return new Response(JSON.stringify({ error: errorMessage }), { status: 500, headers: { "Content-Type": "application/json" } })
      }
  }

  return new Response("Method not allowed. Cuma nerima POST bro.", { status: 405 })
})