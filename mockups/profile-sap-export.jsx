// 13 Profil / Ayarlar, 14 SAP Entegrasyon, 15 Export

function ProfileScreen({ onBack }) {
  const [drawer, setDrawer] = React.useState(false);
  const me = { name: "Zeynep Aksoy", sicil: "GVN-4812", title: "IT Specialist", dept: "Bilgi Teknolojileri", loc: "Ankara Genel Müdürlük", email: "zeynep.aksoy@guvenok.com.tr" };
  const initials = me.name.split(" ").map(n => n[0]).slice(0,2).join("");

  const Row = ({ icon, label, value, toggle, chevron, onClick, danger }) => (
    <div onClick={onClick} style={{
      display: "flex", alignItems: "center", gap: 12, padding: "14px 16px",
      borderBottom: "1px solid var(--surface-divider)", cursor: onClick ? "pointer" : "default",
    }}>
      <div style={{ width: 32, height: 32, borderRadius: 8, background: danger ? "rgba(220,38,38,0.08)" : "var(--surface-light)", display: "flex", alignItems: "center", justifyContent: "center" }}>
        <Icon name={icon} size={15} color={danger ? "var(--error)" : "var(--navy)"} />
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 13, color: danger ? "var(--error)" : "var(--text-primary)", fontWeight: 500 }}>{label}</div>
        {value && <div style={{ fontSize: 11, color: "var(--text-secondary)", marginTop: 2, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>{value}</div>}
      </div>
      {toggle !== undefined && (
        <div style={{ width: 40, height: 22, borderRadius: 11, background: toggle ? "var(--success)" : "var(--surface-divider)", position: "relative", transition: "background .2s" }}>
          <div style={{ position: "absolute", top: 2, left: toggle ? 20 : 2, width: 18, height: 18, borderRadius: "50%", background: "#fff", transition: "left .2s", boxShadow: "0 1px 3px rgba(0,0,0,0.2)" }} />
        </div>
      )}
      {chevron && <Icon name="chevronRight" size={14} color="var(--text-tertiary)" />}
    </div>
  );

  return (
    <div style={{ height: "100%", background: "var(--surface-light)", display: "flex", flexDirection: "column", position: "relative" }}>
      <div style={{ flex: 1, overflow: "auto", paddingBottom: 80 }}>
        <PageHeader title="Profil" back={() => setDrawer(true)} />
        {/* User card */}
        <div style={{ padding: "20px 16px", background: "var(--surface-white)", display: "flex", alignItems: "center", gap: 14, borderBottom: "1px solid var(--surface-divider)" }}>
          <div style={{ width: 60, height: 60, borderRadius: "50%", background: "var(--navy)", color: "#fff", display: "flex", alignItems: "center", justifyContent: "center", fontSize: 20, fontWeight: 500 }}>{initials}</div>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ fontSize: 16, fontWeight: 500 }}>{me.name}</div>
            <div style={{ fontSize: 12, color: "var(--text-secondary)", marginTop: 2 }}>{me.title}</div>
            <div style={{ fontSize: 11, color: "var(--text-tertiary)", marginTop: 2, fontFamily: "ui-monospace, monospace" }}>{me.sicil}</div>
          </div>
          <Icon name="edit" size={16} color="var(--text-tertiary)" />
        </div>

        <div className="section-title" style={{ padding: "16px 16px 6px" }}>HESAP</div>
        <div style={{ background: "var(--surface-white)" }}>
          <Row icon="mail" label="E-posta" value={me.email} chevron />
          <Row icon="users" label="Departman" value={me.dept} chevron />
          <Row icon="flow" label="Lokasyon" value={me.loc} chevron />
          <Row icon="lock" label="Şifre Değiştir" chevron onClick={() => {}} />
        </div>

        <div className="section-title" style={{ padding: "16px 16px 6px" }}>TERCİHLER</div>
        <div style={{ background: "var(--surface-white)" }}>
          <Row icon="bell" label="Bildirimler" toggle={true} />
          <Row icon="mail" label="E-posta bildirimleri" toggle={true} />
          <Row icon="moon" label="Karanlık mod" toggle={false} />
          <Row icon="flow" label="Dil" value="Türkçe" chevron />
        </div>

        <div className="section-title" style={{ padding: "16px 16px 6px" }}>GÜVENLİK</div>
        <div style={{ background: "var(--surface-white)" }}>
          <Row icon="lock" label="İki faktörlü doğrulama" toggle={true} />
          <Row icon="key" label="Aktif oturumlar" value="3 cihaz · son giriş bugün" chevron />
        </div>

        <div className="section-title" style={{ padding: "16px 16px 6px" }}>HAKKINDA</div>
        <div style={{ background: "var(--surface-white)" }}>
          <Row icon="info" label="AssetFlow" value="v2.4.1 · build 2026.04" chevron />
          <Row icon="flow" label="Gizlilik Politikası" chevron />
          <Row icon="flow" label="Kullanım Koşulları" chevron />
        </div>

        <div style={{ background: "var(--surface-white)", marginTop: 12 }}>
          <Row icon="upload" label="Çıkış Yap" danger onClick={() => {}} />
        </div>
      </div>
      <BottomNav active="more" />
      {drawer && <AppDrawer open={drawer} onClose={() => setDrawer(false)} />}
    </div>
  );
}

// ═════════ SAP ENTEGRASYONU ═════════

function SapIntegrationScreen({ onBack }) {
  const [syncing, setSyncing] = React.useState(false);
  const [drawer, setDrawer] = React.useState(false);

  return (
    <div style={{ height: "100%", background: "var(--surface-light)", display: "flex", flexDirection: "column", position: "relative" }}>
      <div style={{ flex: 1, overflow: "auto", paddingBottom: 80 }}>
        <PageHeader title="SAP Entegrasyon" subtitle="CANLI" back={() => setDrawer(true)} />

        {/* Status card */}
        <div style={{ padding: 16 }}>
          <div className="card" style={{ padding: 16, borderLeft: "3px solid var(--success)" }}>
            <div style={{ display: "flex", alignItems: "center", gap: 10, marginBottom: 10 }}>
              <div style={{ width: 10, height: 10, borderRadius: "50%", background: "var(--success)", boxShadow: "0 0 0 4px rgba(22,163,74,0.15)" }} />
              <div style={{ fontSize: 14, fontWeight: 500 }}>Bağlantı Aktif</div>
              <div style={{ marginLeft: "auto", fontSize: 10, color: "var(--text-tertiary)", fontFamily: "ui-monospace, monospace" }}>PRD-GVN-01</div>
            </div>
            <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 10, marginTop: 12 }}>
              <div><div style={{ fontSize: 9, color: "var(--text-tertiary)", letterSpacing: 0.8, textTransform: "uppercase" }}>Endpoint</div><div style={{ fontSize: 11, fontFamily: "ui-monospace, monospace", marginTop: 3 }}>sap.guvenok.com</div></div>
              <div><div style={{ fontSize: 9, color: "var(--text-tertiary)", letterSpacing: 0.8, textTransform: "uppercase" }}>Client</div><div style={{ fontSize: 11, fontFamily: "ui-monospace, monospace", marginTop: 3 }}>100</div></div>
              <div><div style={{ fontSize: 9, color: "var(--text-tertiary)", letterSpacing: 0.8, textTransform: "uppercase" }}>Son Sync</div><div style={{ fontSize: 11, marginTop: 3 }}>21.04.2026 13:15</div></div>
              <div><div style={{ fontSize: 9, color: "var(--text-tertiary)", letterSpacing: 0.8, textTransform: "uppercase" }}>Sonraki</div><div style={{ fontSize: 11, marginTop: 3 }}>21.04.2026 19:15</div></div>
            </div>
          </div>

          {/* Quick actions */}
          <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 10, marginTop: 10 }}>
            <button onClick={() => { setSyncing(true); setTimeout(() => setSyncing(false), 1500); }} style={{
              height: 48, background: "var(--navy)", color: "#fff", border: "none", borderRadius: 8,
              fontFamily: "var(--font)", fontSize: 12, fontWeight: 500, cursor: "pointer",
              display: "flex", alignItems: "center", justifyContent: "center", gap: 6,
            }}>
              {syncing ? <div style={{ width: 14, height: 14, border: "2px solid rgba(255,255,255,0.3)", borderTopColor: "#fff", borderRadius: "50%", animation: "spin 0.8s linear infinite" }} /> : <Icon name="refresh" size={13} color="#fff" />}
              {syncing ? "Senkronize ediliyor..." : "Şimdi Senkronize Et"}
            </button>
            <button style={{ height: 48, background: "var(--surface-white)", color: "var(--navy)", border: "1px solid var(--surface-input-border)", borderRadius: 8, fontFamily: "var(--font)", fontSize: 12, fontWeight: 500, cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", gap: 6 }}>
              <Icon name="flow" size={13} color="var(--navy)" />
              Ayarlar
            </button>
          </div>

          {/* Metrics */}
          <div className="section-title" style={{ marginTop: 16, marginBottom: 8, paddingLeft: 4 }}>BUGÜNKÜ SENKRONİZASYON</div>
          <div className="card" style={{ padding: "4px 16px" }}>
            {[
              { label: "Güncellenen Cihaz", value: 24, color: "var(--info)" },
              { label: "Yeni Kayıt", value: 3, color: "var(--success)" },
              { label: "Çakışma", value: 0, color: "var(--text-tertiary)" },
              { label: "Hata", value: 0, color: "var(--text-tertiary)" },
            ].map((m, i, arr) => (
              <div key={i} style={{ display: "flex", justifyContent: "space-between", alignItems: "center", padding: "12px 0", borderBottom: i < arr.length - 1 ? "1px solid var(--surface-divider)" : "none" }}>
                <span style={{ fontSize: 12, color: "var(--text-secondary)" }}>{m.label}</span>
                <span style={{ fontSize: 15, fontWeight: 500, color: m.color }}>{m.value}</span>
              </div>
            ))}
          </div>

          {/* Recent logs */}
          <div className="section-title" style={{ marginTop: 16, marginBottom: 8, paddingLeft: 4 }}>SON İŞLEMLER</div>
          <div className="card" style={{ padding: "4px 16px" }}>
            {[
              { when: "13:15", action: "Tam senkronizasyon", detail: "27 işlem · 0 hata", ok: true },
              { when: "07:15", action: "Delta senkronizasyon", detail: "4 işlem · 0 hata", ok: true },
              { when: "20.04 · 19:15", action: "Tam senkronizasyon", detail: "18 işlem · 0 hata", ok: true },
              { when: "20.04 · 13:15", action: "Bağlantı kesildi", detail: "Timeout · 3. denemede başarılı", ok: false },
            ].map((log, i, arr) => (
              <div key={i} style={{ display: "flex", alignItems: "center", gap: 10, padding: "12px 0", borderBottom: i < arr.length - 1 ? "1px solid var(--surface-divider)" : "none" }}>
                <div style={{ width: 6, height: 6, borderRadius: "50%", background: log.ok ? "var(--success)" : "var(--warning)" }} />
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ fontSize: 12, fontWeight: 500 }}>{log.action}</div>
                  <div style={{ fontSize: 10, color: "var(--text-tertiary)", marginTop: 2 }}>{log.detail}</div>
                </div>
                <span style={{ fontSize: 10, color: "var(--text-tertiary)" }}>{log.when}</span>
              </div>
            ))}
          </div>
        </div>
      </div>
      <BottomNav active="more" />
      {drawer && <AppDrawer open={drawer} onClose={() => setDrawer(false)} />}
      <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>
    </div>
  );
}

// ═════════ EXPORT ═════════

function ExportScreen({ onBack }) {
  const [format, setFormat] = React.useState("xlsx");
  const [scope, setScope]   = React.useState("all");
  const [fields, setFields] = React.useState({ basic: true, hardware: true, warranty: true, assignment: true, history: false });
  const [drawer, setDrawer] = React.useState(false);

  const formats = [
    { id: "xlsx", label: "Excel", ext: ".xlsx", icon: "download" },
    { id: "csv",  label: "CSV",   ext: ".csv",  icon: "download" },
    { id: "pdf",  label: "PDF",   ext: ".pdf",  icon: "download" },
  ];
  const scopes = [
    { id: "all",       label: "Tüm Cihazlar",     count: "158 kayıt" },
    { id: "assigned",  label: "Zimmetli Cihazlar", count: "94 kayıt" },
    { id: "storage",   label: "Depodaki Cihazlar", count: "52 kayıt" },
    { id: "maintenance", label: "Bakımdaki Cihazlar", count: "8 kayıt" },
    { id: "custom",    label: "Özel Filtre", count: "Filtre seç" },
  ];

  return (
    <div style={{ height: "100%", background: "var(--surface-light)", display: "flex", flexDirection: "column", position: "relative" }}>
      <div style={{ flex: 1, overflow: "auto", paddingBottom: 90 }}>
        <PageHeader title="Dışa Aktar" back={() => setDrawer(true)} />

        <div style={{ padding: 16 }}>
          {/* Format */}
          <div className="section-title" style={{ marginBottom: 10, paddingLeft: 4 }}>FORMAT</div>
          <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr 1fr", gap: 8 }}>
            {formats.map(f => {
              const active = format === f.id;
              return (
                <button key={f.id} onClick={() => setFormat(f.id)} style={{
                  padding: "14px 10px", background: active ? "var(--navy)" : "var(--surface-white)",
                  color: active ? "#fff" : "var(--text-primary)",
                  border: "1px solid", borderColor: active ? "var(--navy)" : "var(--surface-input-border)",
                  borderRadius: 8, cursor: "pointer", fontFamily: "var(--font)",
                  display: "flex", flexDirection: "column", alignItems: "center", gap: 4,
                }}>
                  <Icon name={f.icon} size={16} color={active ? "#fff" : "var(--navy)"} />
                  <div style={{ fontSize: 12, fontWeight: 500, marginTop: 4 }}>{f.label}</div>
                  <div style={{ fontSize: 9, opacity: 0.6, fontFamily: "ui-monospace, monospace" }}>{f.ext}</div>
                </button>
              );
            })}
          </div>

          {/* Scope */}
          <div className="section-title" style={{ marginTop: 18, marginBottom: 10, paddingLeft: 4 }}>KAPSAM</div>
          <div className="card" style={{ padding: "4px 0" }}>
            {scopes.map((s, i) => (
              <div key={s.id} onClick={() => setScope(s.id)} style={{
                display: "flex", alignItems: "center", gap: 12, padding: "12px 16px",
                borderBottom: i < scopes.length - 1 ? "1px solid var(--surface-divider)" : "none",
                cursor: "pointer",
              }}>
                <div style={{
                  width: 18, height: 18, borderRadius: "50%",
                  border: "2px solid", borderColor: scope === s.id ? "var(--navy)" : "var(--surface-input-border)",
                  display: "flex", alignItems: "center", justifyContent: "center",
                }}>
                  {scope === s.id && <div style={{ width: 8, height: 8, borderRadius: "50%", background: "var(--navy)" }} />}
                </div>
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: 13, fontWeight: 500 }}>{s.label}</div>
                  <div style={{ fontSize: 11, color: "var(--text-tertiary)", marginTop: 2 }}>{s.count}</div>
                </div>
              </div>
            ))}
          </div>

          {/* Fields */}
          <div className="section-title" style={{ marginTop: 18, marginBottom: 10, paddingLeft: 4 }}>ALANLAR</div>
          <div className="card" style={{ padding: "4px 16px" }}>
            {[
              { id: "basic", label: "Temel Bilgiler", sub: "Ad, kod, tip, durum" },
              { id: "hardware", label: "Donanım", sub: "CPU, RAM, depolama, OS" },
              { id: "warranty", label: "Garanti", sub: "Satın alma, fatura, süre" },
              { id: "assignment", label: "Zimmet", sub: "Kişi, tarih, lokasyon" },
              { id: "history", label: "Geçmiş", sub: "Değişiklik günlüğü" },
            ].map((field, i, arr) => (
              <label key={field.id} style={{
                display: "flex", alignItems: "flex-start", gap: 10, padding: "12px 0",
                borderBottom: i < arr.length - 1 ? "1px solid var(--surface-divider)" : "none",
                cursor: "pointer",
              }}>
                <input type="checkbox" checked={fields[field.id]} onChange={e => setFields({...fields, [field.id]: e.target.checked})} style={{ marginTop: 2, accentColor: "var(--navy)" }} />
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: 13, color: "var(--text-primary)" }}>{field.label}</div>
                  <div style={{ fontSize: 11, color: "var(--text-secondary)", marginTop: 2 }}>{field.sub}</div>
                </div>
              </label>
            ))}
          </div>

          {/* Preview */}
          <div style={{ marginTop: 18, padding: 14, background: "rgba(26,58,92,0.04)", borderRadius: 8, display: "flex", alignItems: "center", gap: 10 }}>
            <Icon name="info" size={14} color="var(--navy)" />
            <div style={{ flex: 1, fontSize: 11, color: "var(--text-secondary)", lineHeight: 1.5 }}>
              Önizleme: <b style={{ color: "var(--text-primary)", fontFamily: "ui-monospace, monospace" }}>guvenok-cihazlar-20260421.{format}</b><br/>
              ~{Object.values(fields).filter(Boolean).length * 4} sütun · tahmini 0.{scope === "all" ? "8" : "3"} MB
            </div>
          </div>
        </div>
      </div>

      <div style={{ position: "absolute", left: 16, right: 16, bottom: 24 }}>
        <button style={{
          width: "100%", height: 50, background: "var(--navy)", color: "#fff",
          border: "none", borderRadius: 10, fontFamily: "var(--font)",
          fontSize: 14, fontWeight: 500, cursor: "pointer",
          boxShadow: "0 6px 18px rgba(26,58,92,0.25)",
          display: "flex", alignItems: "center", justifyContent: "center", gap: 8,
        }}>
          <Icon name="download" size={16} color="#fff" />
          Dışa Aktar
        </button>
      </div>
      {drawer && <AppDrawer open={drawer} onClose={() => setDrawer(false)} />}
    </div>
  );
}

Object.assign(window, { ProfileScreen, SapIntegrationScreen, ExportScreen });
