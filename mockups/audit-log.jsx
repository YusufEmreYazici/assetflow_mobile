// 08 Audit Log — merkezi değişiklik günlüğü (tüm cihazlar, tüm kullanıcılar)

const AUDIT_FEED = [
  { id: 1, when: "21.04.2026 14:32", user: "Zeynep Aksoy",   action: "Zimmet oluşturdu", entity: "ZMT-20260421-0142 · Dell Latitude 5540", kind: "create",   target: "Mehmet Yılmaz" },
  { id: 2, when: "21.04.2026 11:18", user: "Ahmet Kaya",     action: "Cihaz durumu değiştirdi", entity: "GVN-LPT-0089 · HP EliteBook", kind: "update", changes: [{ field: "Durum", before: "Aktif", after: "Bakımda" }] },
  { id: 3, when: "21.04.2026 09:47", user: "Emine Çelik",    action: "Cihaz ekledi", entity: "GVN-MON-0201 · Dell U2723QE", kind: "create" },
  { id: 4, when: "20.04.2026 17:02", user: "Burak Yıldız",   action: "İade aldı",    entity: "GVN-TEL-0056 · iPhone 14",  kind: "update",   target: "Ayşe Demir" },
  { id: 5, when: "20.04.2026 15:30", user: "Zeynep Aksoy",   action: "Lokasyon güncelledi", entity: "GVN-LPT-0087", kind: "update", changes: [{ field: "Lokasyon", before: "Ankara Genel Müdürlük", after: "Mersin Limanı" }] },
  { id: 6, when: "20.04.2026 13:15", user: "Sistem (SAP)",   action: "SAP senkronizasyonu", entity: "24 cihaz güncellendi · 3 yeni kayıt", kind: "system" },
  { id: 7, when: "20.04.2026 10:48", user: "Ahmet Kaya",     action: "Cihaz emekliye ayırdı", entity: "GVN-LPT-0012 · Dell Latitude 5410", kind: "delete" },
  { id: 8, when: "19.04.2026 16:20", user: "Emine Çelik",    action: "Kullanıcı ekledi", entity: "Canan Öztürk · Mersin Limanı", kind: "create" },
  { id: 9, when: "19.04.2026 14:05", user: "Zeynep Aksoy",   action: "Zimmet iptali", entity: "ZMT-20260315-0118", kind: "delete", target: "Fatih Demir" },
  { id: 10, when: "19.04.2026 11:42", user: "Burak Yıldız",  action: "Toplu güncelleme", entity: "12 cihazın garanti süresi güncellendi", kind: "update" },
  { id: 11, when: "18.04.2026 17:30", user: "Sistem",        action: "Otomatik uyarı gönderildi", entity: "7 cihaz garantisi 30 gün içinde bitiyor", kind: "system" },
  { id: 12, when: "18.04.2026 14:18", user: "Ahmet Kaya",    action: "Donanım güncellendi", entity: "GVN-LPT-0047", kind: "update", changes: [{ field: "RAM", before: "8 GB", after: "16 GB" },{ field: "SSD", before: "256 GB", after: "512 GB" }] },
];

const AUDIT_FILTERS = ["Tümü","Oluşturma","Güncelleme","Silme","Sistem"];

function auditKindColor(kind) {
  return kind === "create" ? "var(--success)" :
         kind === "update" ? "var(--info)" :
         kind === "delete" ? "var(--error)" :
         "var(--text-secondary)";
}
function auditKindLabel(kind) {
  return { create: "CREATE", update: "UPDATE", delete: "DELETE", system: "SYSTEM" }[kind] || kind.toUpperCase();
}

function AuditLogScreen({ onBack }) {
  const [filter, setFilter] = React.useState("Tümü");
  const [expanded, setExpanded] = React.useState(null);
  const [drawer, setDrawer] = React.useState(false);

  const filtered = AUDIT_FEED.filter(l => {
    if (filter === "Tümü") return true;
    const map = { "Oluşturma": "create", "Güncelleme": "update", "Silme": "delete", "Sistem": "system" };
    return l.kind === map[filter];
  });

  // group by date
  const groups = {};
  filtered.forEach(l => {
    const date = l.when.split(" ")[0];
    (groups[date] = groups[date] || []).push(l);
  });

  return (
    <div style={{ height: "100%", background: "var(--surface-light)", display: "flex", flexDirection: "column", position: "relative" }}>
      <div style={{ flex: 1, overflow: "auto", paddingBottom: 80 }}>
        <PageHeader title="Audit Log" subtitle={`${filtered.length} KAYIT`} back={() => setDrawer(true)}
          action={
            <button style={{ width: 36, height: 36, borderRadius: 8, background: "rgba(255,255,255,0.10)", border: "none", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center" }}>
              <Icon name="download" size={16} color="#fff" />
            </button>
          } />
        {/* Filter chips */}
        <div style={{ padding: "12px 16px", background: "var(--surface-white)", borderBottom: "1px solid var(--surface-divider)", overflowX: "auto", whiteSpace: "nowrap" }}>
          {AUDIT_FILTERS.map(f => (
            <button key={f} onClick={() => setFilter(f)} style={{
              display: "inline-block", marginRight: 8, padding: "6px 12px",
              background: filter === f ? "var(--navy)" : "var(--surface-light)",
              color: filter === f ? "#fff" : "var(--text-secondary)",
              border: "none", borderRadius: 16, fontFamily: "var(--font)",
              fontSize: 11, fontWeight: 500, letterSpacing: 0.4, cursor: "pointer",
              textTransform: "uppercase",
            }}>{f}</button>
          ))}
        </div>

        {/* Grouped list */}
        {Object.keys(groups).map(date => (
          <div key={date}>
            <div style={{ padding: "10px 16px 6px", fontSize: 10, fontWeight: 500, letterSpacing: 1.2, color: "var(--text-tertiary)", textTransform: "uppercase" }}>{date}</div>
            <div style={{ background: "var(--surface-white)" }}>
              {groups[date].map((l, i) => {
                const isExp = expanded === l.id;
                return (
                  <div key={l.id} onClick={() => l.changes && setExpanded(isExp ? null : l.id)} style={{
                    padding: "12px 16px",
                    borderBottom: i < groups[date].length - 1 ? "1px solid var(--surface-divider)" : "none",
                    cursor: l.changes ? "pointer" : "default",
                  }}>
                    <div style={{ display: "flex", alignItems: "flex-start", gap: 10 }}>
                      <div style={{ width: 6, height: 6, borderRadius: "50%", background: auditKindColor(l.kind), marginTop: 6, flexShrink: 0 }} />
                      <div style={{ flex: 1, minWidth: 0 }}>
                        <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 3 }}>
                          <span style={{ fontSize: 9, fontWeight: 500, letterSpacing: 1, color: auditKindColor(l.kind), padding: "2px 6px", background: "rgba(0,0,0,0.03)", borderRadius: 3 }}>{auditKindLabel(l.kind)}</span>
                          <span style={{ fontSize: 10, color: "var(--text-tertiary)" }}>{l.when.split(" ")[1]}</span>
                        </div>
                        <div style={{ fontSize: 13, color: "var(--text-primary)", marginBottom: 3 }}>
                          <b style={{ fontWeight: 500 }}>{l.user}</b> <span style={{ color: "var(--text-secondary)" }}>{l.action.toLowerCase()}</span>
                          {l.target && <> · <span style={{ color: "var(--text-secondary)" }}>{l.target}</span></>}
                        </div>
                        <div style={{ fontSize: 11, color: "var(--text-tertiary)", fontFamily: l.entity.startsWith("GVN") || l.entity.startsWith("ZMT") ? "ui-monospace, monospace" : "var(--font)" }}>
                          {l.entity}
                        </div>
                      </div>
                      {l.changes && <Icon name={isExp ? "chevronUp" : "chevronDown"} size={14} color="var(--text-tertiary)" />}
                    </div>
                    {l.changes && isExp && (
                      <div style={{ marginTop: 10, marginLeft: 16, paddingTop: 10, borderTop: "1px solid var(--surface-divider)" }}>
                        {l.changes.map((c, j) => (
                          <div key={j} style={{ marginBottom: 6 }}>
                            <div style={{ fontSize: 9, fontWeight: 500, letterSpacing: 0.8, color: "var(--text-secondary)", textTransform: "uppercase", marginBottom: 3 }}>{c.field}</div>
                            <div style={{ display: "flex", alignItems: "center", gap: 6, fontSize: 11, flexWrap: "wrap" }}>
                              <span style={{ color: "var(--error)", textDecoration: "line-through" }}>{c.before}</span>
                              <Icon name="arrowRight" size={10} color="var(--text-tertiary)" />
                              <span style={{ color: "var(--success)", fontWeight: 500 }}>{c.after}</span>
                            </div>
                          </div>
                        ))}
                      </div>
                    )}
                  </div>
                );
              })}
            </div>
          </div>
        ))}
      </div>
      <BottomNav active="more" />
      {drawer && <AppDrawer open={drawer} onClose={() => setDrawer(false)} />}
    </div>
  );
}

Object.assign(window, { AuditLogScreen });
