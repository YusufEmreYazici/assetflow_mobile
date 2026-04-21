// 16 Empty / Loading / Error states — demo frames

function EmptyState({ icon, title, body, cta }) {
  return (
    <div style={{ height: "100%", display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", padding: 32, textAlign: "center", background: "var(--surface-light)" }}>
      <div style={{ width: 72, height: 72, borderRadius: "50%", background: "rgba(26,58,92,0.06)", display: "flex", alignItems: "center", justifyContent: "center", marginBottom: 16 }}>
        <Icon name={icon} size={30} color="var(--navy)" />
      </div>
      <div style={{ fontSize: 16, fontWeight: 500, color: "var(--text-primary)", marginBottom: 6 }}>{title}</div>
      <div style={{ fontSize: 12, color: "var(--text-secondary)", lineHeight: 1.5, maxWidth: 260, marginBottom: 20 }}>{body}</div>
      {cta && (
        <button style={{ padding: "10px 20px", background: "var(--navy)", color: "#fff", border: "none", borderRadius: 8, fontFamily: "var(--font)", fontSize: 12, fontWeight: 500, cursor: "pointer" }}>
          {cta}
        </button>
      )}
    </div>
  );
}

function LoadingState() {
  return (
    <div style={{ height: "100%", display: "flex", flexDirection: "column", background: "var(--surface-light)" }}>
      <PageHeader title="Cihazlar" subtitle="YÜKLENİYOR..." />
      <div style={{ padding: 16 }}>
        {[1,2,3,4,5].map(i => (
          <div key={i} className="card" style={{ marginBottom: 8, padding: 12, display: "flex", alignItems: "center", gap: 12 }}>
            <div className="skel" style={{ width: 40, height: 40, borderRadius: 8 }} />
            <div style={{ flex: 1 }}>
              <div className="skel" style={{ height: 13, width: "65%", borderRadius: 4, marginBottom: 8 }} />
              <div className="skel" style={{ height: 10, width: "40%", borderRadius: 4 }} />
            </div>
            <div className="skel" style={{ width: 50, height: 18, borderRadius: 9 }} />
          </div>
        ))}
      </div>
      <style>{`
        .skel {
          background: linear-gradient(90deg, rgba(0,0,0,0.05) 0%, rgba(0,0,0,0.08) 50%, rgba(0,0,0,0.05) 100%);
          background-size: 200% 100%;
          animation: skel 1.4s ease-in-out infinite;
        }
        @keyframes skel { 0% { background-position: 200% 0 } 100% { background-position: -200% 0 } }
      `}</style>
    </div>
  );
}

function ErrorState({ kind = "network" }) {
  const cfg = {
    network: { icon: "warning", title: "Bağlantı Hatası", body: "Sunucuya ulaşılamadı. İnternet bağlantınızı kontrol edin ve tekrar deneyin.", cta: "Yeniden Dene", color: "var(--error)" },
    "403":   { icon: "lock",    title: "Yetkisiz Erişim",  body: "Bu kaydı görüntülemek için yetkiniz bulunmuyor. BT yöneticinizle iletişime geçin.", cta: "Ana Sayfa", color: "var(--warning)" },
    "500":   { icon: "warning", title: "Sunucu Hatası",     body: "Beklenmeyen bir hata oluştu. Sorun devam ederse kayıt kodu ile destek ekibine ulaşın.", cta: "Yeniden Dene", color: "var(--error)" },
  }[kind];
  return (
    <div style={{ height: "100%", display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", padding: 32, textAlign: "center", background: "var(--surface-light)" }}>
      <div style={{ width: 72, height: 72, borderRadius: "50%", background: `${cfg.color}14`, display: "flex", alignItems: "center", justifyContent: "center", marginBottom: 16 }}>
        <Icon name={cfg.icon} size={30} color={cfg.color} />
      </div>
      <div style={{ fontSize: 16, fontWeight: 500, color: "var(--text-primary)", marginBottom: 6 }}>{cfg.title}</div>
      <div style={{ fontSize: 12, color: "var(--text-secondary)", lineHeight: 1.5, maxWidth: 260, marginBottom: 20 }}>{cfg.body}</div>
      <div style={{ display: "flex", gap: 8 }}>
        <button style={{ padding: "10px 20px", background: "var(--navy)", color: "#fff", border: "none", borderRadius: 8, fontFamily: "var(--font)", fontSize: 12, fontWeight: 500, cursor: "pointer" }}>
          {cfg.cta}
        </button>
        <button style={{ padding: "10px 20px", background: "transparent", color: "var(--text-secondary)", border: "1px solid var(--surface-input-border)", borderRadius: 8, fontFamily: "var(--font)", fontSize: 12, fontWeight: 500, cursor: "pointer" }}>
          Destek
        </button>
      </div>
      {kind !== "network" && (
        <div style={{ marginTop: 20, fontSize: 10, color: "var(--text-tertiary)", fontFamily: "ui-monospace, monospace" }}>
          ERR-{kind.toUpperCase()}-20260421-A8F2
        </div>
      )}
    </div>
  );
}

function OfflineBanner() {
  return (
    <div style={{ height: "100%", display: "flex", flexDirection: "column", background: "var(--surface-light)" }}>
      <div style={{ background: "var(--warning)", color: "#fff", padding: "10px 16px", display: "flex", alignItems: "center", gap: 10 }}>
        <Icon name="warning" size={14} color="#fff" />
        <div style={{ fontSize: 12, flex: 1 }}>Çevrimdışı mod · değişiklikler senkronize edilecek</div>
      </div>
      <PageHeader title="Cihazlar" subtitle="ÖNBELLEK · 158 CİHAZ" />
      <div style={{ padding: 16 }}>
        {DEVICES.slice(0, 4).map(d => (
          <div key={d.id} className="card" style={{ marginBottom: 8, padding: 12, display: "flex", alignItems: "center", gap: 12, opacity: 0.7 }}>
            <div style={{ width: 40, height: 40, borderRadius: 8, background: "var(--surface-light)", display: "flex", alignItems: "center", justifyContent: "center" }}>
              <Icon name={deviceIcon(d.type)} size={16} color="var(--navy)" />
            </div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontSize: 13, fontWeight: 500, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>{d.name}</div>
              <div style={{ fontSize: 10, color: "var(--text-tertiary)", fontFamily: "ui-monospace, monospace", marginTop: 2 }}>{d.code}</div>
            </div>
            <Chip tone={statusTone(d.status)}>{d.status}</Chip>
          </div>
        ))}
      </div>
    </div>
  );
}

Object.assign(window, { EmptyState, LoadingState, ErrorState, OfflineBanner });
