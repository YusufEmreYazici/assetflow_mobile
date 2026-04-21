// 11 Lokasyon Liste + Detay, 12 Bildirim Merkezi

const LOCATION_DATA = [
  { name: "Ankara Genel Müdürlük",  type: "Genel Müdürlük", devices: 58, people: 142, active: 56, storage: 2 },
  { name: "Mersin Limanı",           type: "Liman Tesisi",   devices: 34, people: 89,  active: 31, storage: 3 },
  { name: "İzmit Terminal",          type: "Terminal",       devices: 22, people: 54,  active: 20, storage: 2 },
  { name: "Aliağa Rafineri",         type: "Rafineri",       devices: 18, people: 41,  active: 17, storage: 1 },
  { name: "İstanbul Kartal Ofis",    type: "Bölge Ofisi",    devices: 14, people: 28,  active: 13, storage: 1 },
  { name: "Samsun Depo",             type: "Depo",           devices: 6,  people: 11,  active: 5,  storage: 1 },
  { name: "Adana Terminal",          type: "Terminal",       devices: 4,  people: 9,   active: 4,  storage: 0 },
  { name: "Kocaeli Körfez",          type: "Terminal",       devices: 2,  people: 7,   active: 2,  storage: 0 },
];

function LocationListScreen({ onBack, onOpen }) {
  const [search, setSearch] = React.useState("");
  const [drawer, setDrawer] = React.useState(false);
  const filtered = LOCATION_DATA.filter(l => !search || l.name.toLowerCase().includes(search.toLowerCase()));
  const totalDevices = LOCATION_DATA.reduce((s, l) => s + l.devices, 0);

  return (
    <div style={{ height: "100%", background: "var(--surface-light)", display: "flex", flexDirection: "column", position: "relative" }}>
      <div style={{ flex: 1, overflow: "auto", paddingBottom: 80 }}>
        <PageHeader title="Lokasyonlar" subtitle={`${filtered.length} TESİS · ${totalDevices} CİHAZ`} back={() => setDrawer(true)} />
        <div style={{ padding: 12, background: "var(--surface-white)", borderBottom: "1px solid var(--surface-divider)" }}>
          <div style={{ position: "relative" }}>
            <div style={{ position: "absolute", left: 12, top: "50%", transform: "translateY(-50%)" }}>
              <Icon name="search" size={14} color="var(--text-tertiary)" />
            </div>
            <input value={search} onChange={e => setSearch(e.target.value)} placeholder="Lokasyon ara..." className="input" style={{ paddingLeft: 36, fontSize: 13 }} />
          </div>
        </div>
        <div style={{ padding: 16 }}>
          {filtered.map((l, i) => {
            const pct = Math.round((l.active / l.devices) * 100);
            return (
              <div key={l.name} onClick={() => onOpen && onOpen(l)} className="card" style={{ marginBottom: 10, padding: 14, cursor: "pointer" }}>
                <div style={{ display: "flex", alignItems: "flex-start", gap: 12 }}>
                  <div style={{ width: 40, height: 40, borderRadius: 8, background: "rgba(26,58,92,0.08)", display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
                    <Icon name="flow" size={18} color="var(--navy)" />
                  </div>
                  <div style={{ flex: 1, minWidth: 0 }}>
                    <div style={{ fontSize: 14, fontWeight: 500, color: "var(--text-primary)" }}>{l.name}</div>
                    <div style={{ fontSize: 10, color: "var(--text-tertiary)", letterSpacing: 0.6, textTransform: "uppercase", marginTop: 2 }}>{l.type}</div>
                  </div>
                  <Icon name="chevronRight" size={14} color="var(--text-tertiary)" />
                </div>
                <div style={{ marginTop: 12, display: "grid", gridTemplateColumns: "1fr 1fr 1fr", gap: 10 }}>
                  <div>
                    <div style={{ fontSize: 9, color: "var(--text-tertiary)", letterSpacing: 0.8, textTransform: "uppercase" }}>Cihaz</div>
                    <div style={{ fontSize: 16, fontWeight: 500, color: "var(--text-primary)", marginTop: 2 }}>{l.devices}</div>
                  </div>
                  <div>
                    <div style={{ fontSize: 9, color: "var(--text-tertiary)", letterSpacing: 0.8, textTransform: "uppercase" }}>Personel</div>
                    <div style={{ fontSize: 16, fontWeight: 500, color: "var(--text-primary)", marginTop: 2 }}>{l.people}</div>
                  </div>
                  <div>
                    <div style={{ fontSize: 9, color: "var(--text-tertiary)", letterSpacing: 0.8, textTransform: "uppercase" }}>Aktif</div>
                    <div style={{ fontSize: 16, fontWeight: 500, color: "var(--success)", marginTop: 2 }}>{pct}%</div>
                  </div>
                </div>
                <div style={{ marginTop: 10, height: 4, background: "var(--surface-light)", borderRadius: 2, overflow: "hidden" }}>
                  <div style={{ width: `${pct}%`, height: "100%", background: "var(--success)" }} />
                </div>
              </div>
            );
          })}
        </div>
      </div>
      <BottomNav active="more" />
      {drawer && <AppDrawer open={drawer} onClose={() => setDrawer(false)} />}
    </div>
  );
}

function LocationDetailScreen({ loc, onBack }) {
  const l = loc || LOCATION_DATA[0];
  const [tab, setTab] = React.useState("Cihazlar");
  const localDevices = DEVICES.slice(0, 6);

  return (
    <div style={{ height: "100%", background: "var(--surface-light)", display: "flex", flexDirection: "column" }}>
      <div style={{ background: "var(--navy)", color: "#fff", padding: "12px 16px 20px" }}>
        <div style={{ display: "flex", alignItems: "center", gap: 10, marginBottom: 14 }}>
          <button onClick={onBack} style={{ width: 36, height: 36, borderRadius: 8, background: "rgba(255,255,255,0.10)", border: "none", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center" }}><Icon name="chevronLeft" size={18} color="#fff" /></button>
          <div style={{ flex: 1, fontSize: 10, fontWeight: 500, letterSpacing: 1.4, color: "rgba(255,255,255,0.6)", textTransform: "uppercase" }}>{l.type}</div>
        </div>
        <div style={{ fontSize: 20, fontWeight: 500, letterSpacing: -0.2 }}>{l.name}</div>
        <div style={{ marginTop: 14, display: "grid", gridTemplateColumns: "1fr 1fr 1fr 1fr", gap: 8 }}>
          <div style={{ background: "rgba(255,255,255,0.08)", padding: "8px 10px", borderRadius: 6 }}>
            <div style={{ fontSize: 9, letterSpacing: 0.8, color: "rgba(255,255,255,0.6)", textTransform: "uppercase" }}>Cihaz</div>
            <div style={{ fontSize: 14, fontWeight: 500, marginTop: 2 }}>{l.devices}</div>
          </div>
          <div style={{ background: "rgba(255,255,255,0.08)", padding: "8px 10px", borderRadius: 6 }}>
            <div style={{ fontSize: 9, letterSpacing: 0.8, color: "rgba(255,255,255,0.6)", textTransform: "uppercase" }}>Kişi</div>
            <div style={{ fontSize: 14, fontWeight: 500, marginTop: 2 }}>{l.people}</div>
          </div>
          <div style={{ background: "rgba(255,255,255,0.08)", padding: "8px 10px", borderRadius: 6 }}>
            <div style={{ fontSize: 9, letterSpacing: 0.8, color: "rgba(255,255,255,0.6)", textTransform: "uppercase" }}>Aktif</div>
            <div style={{ fontSize: 14, fontWeight: 500, marginTop: 2 }}>{l.active}</div>
          </div>
          <div style={{ background: "rgba(255,255,255,0.08)", padding: "8px 10px", borderRadius: 6 }}>
            <div style={{ fontSize: 9, letterSpacing: 0.8, color: "rgba(255,255,255,0.6)", textTransform: "uppercase" }}>Depo</div>
            <div style={{ fontSize: 14, fontWeight: 500, marginTop: 2 }}>{l.storage}</div>
          </div>
        </div>
      </div>
      <TabBar tabs={["Cihazlar","Personel","Depolar"]} active={tab} onChange={setTab} />
      <div style={{ flex: 1, overflow: "auto", padding: 16 }}>
        {tab === "Cihazlar" && (
          <div className="card" style={{ padding: "4px 0" }}>
            {localDevices.map((d, i) => (
              <div key={d.id} style={{
                display: "flex", alignItems: "center", gap: 12, padding: "12px 16px",
                borderBottom: i < localDevices.length - 1 ? "1px solid var(--surface-divider)" : "none",
              }}>
                <div style={{ width: 36, height: 36, borderRadius: 8, background: "var(--surface-light)", display: "flex", alignItems: "center", justifyContent: "center" }}>
                  <Icon name={deviceIcon(d.type)} size={16} color="var(--navy)" />
                </div>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ fontSize: 13, fontWeight: 500, color: "var(--text-primary)", whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>{d.name}</div>
                  <div style={{ fontSize: 10, color: "var(--text-tertiary)", fontFamily: "ui-monospace, monospace", marginTop: 2 }}>{d.code}</div>
                </div>
                <Chip tone={statusTone(d.status)}>{d.status}</Chip>
              </div>
            ))}
          </div>
        )}
        {tab === "Personel" && (
          <div style={{ padding: "40px 20px", textAlign: "center" }}>
            <Icon name="users" size={36} color="var(--text-tertiary)" />
            <div style={{ fontSize: 13, color: "var(--text-secondary)", marginTop: 12 }}>{l.people} kişi listeleniyor</div>
          </div>
        )}
        {tab === "Depolar" && (
          <div>
            {Array.from({ length: l.storage || 1 }).map((_, i) => (
              <div key={i} className="card" style={{ marginBottom: 10, padding: 14 }}>
                <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
                  <Icon name="box" size={18} color="var(--navy)" />
                  <div style={{ flex: 1 }}>
                    <div style={{ fontSize: 13, fontWeight: 500 }}>Depo #{i+1} · {l.name.split(" ")[0]}</div>
                    <div style={{ fontSize: 11, color: "var(--text-tertiary)", marginTop: 2 }}>{Math.floor(Math.random()*15 + 3)} cihaz</div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

// ═════════ BİLDİRİM MERKEZİ ═════════

const NOTIFICATIONS = [
  { id: 1, kind: "warning", when: "2 saat önce", title: "Garanti süresi doluyor", body: "7 cihazın garantisi 30 gün içinde bitiyor", read: false },
  { id: 2, kind: "info",    when: "4 saat önce", title: "Zimmet onayı bekliyor", body: "Murat Arslan'dan 2 zimmet onayı bekliyor", read: false },
  { id: 3, kind: "success", when: "Bugün 09:12", title: "SAP senkronizasyonu başarılı", body: "24 cihaz güncellendi, 3 yeni kayıt eklendi", read: false },
  { id: 4, kind: "error",   when: "Dün 17:48",   title: "Kayıp cihaz raporu", body: "GVN-TEL-0034 · iPhone 13 Pro · 3 gündür görülmedi", read: true },
  { id: 5, kind: "info",    when: "Dün 14:20",   title: "Yeni zimmet talebi", body: "Canan Öztürk · Laptop talebi oluşturdu", read: true },
  { id: 6, kind: "warning", when: "Pzt 11:05",   title: "Stok seviyesi düşük", body: "Depoda sadece 2 laptop kaldı · min. 5 önerilir", read: true },
  { id: 7, kind: "success", when: "Pzt 09:30",   title: "Aylık rapor hazır", body: "Mart 2026 cihaz envanter raporu oluşturuldu", read: true },
  { id: 8, kind: "info",    when: "Cmt 16:15",   title: "Sistem güncelleme", body: "AssetFlow v2.4.1 yayınlandı · yenilikleri gör", read: true },
];

function notifIcon(kind) {
  return { warning: "warning", info: "info", success: "check", error: "warning" }[kind];
}
function notifColor(kind) {
  return { warning: "var(--warning)", info: "var(--info)", success: "var(--success)", error: "var(--error)" }[kind];
}

function NotificationsScreen({ onBack }) {
  const [filter, setFilter] = React.useState("Tümü");
  const [drawer, setDrawer] = React.useState(false);
  const filtered = NOTIFICATIONS.filter(n => {
    if (filter === "Tümü") return true;
    if (filter === "Okunmamış") return !n.read;
    const map = { "Uyarı": "warning", "Bilgi": "info", "Başarı": "success", "Hata": "error" };
    return n.kind === map[filter];
  });
  const unread = NOTIFICATIONS.filter(n => !n.read).length;

  return (
    <div style={{ height: "100%", background: "var(--surface-light)", display: "flex", flexDirection: "column", position: "relative" }}>
      <div style={{ flex: 1, overflow: "auto", paddingBottom: 80 }}>
        <PageHeader title="Bildirimler" subtitle={`${unread} OKUNMAMIŞ`} back={() => setDrawer(true)}
          action={
            <button style={{ height: 28, padding: "0 10px", borderRadius: 6, background: "rgba(255,255,255,0.10)", color: "#fff", border: "none", cursor: "pointer", fontSize: 11, fontFamily: "var(--font)", fontWeight: 500 }}>
              Tümünü Oku
            </button>
          } />
        <div style={{ padding: "12px 16px", background: "var(--surface-white)", borderBottom: "1px solid var(--surface-divider)", overflowX: "auto", whiteSpace: "nowrap" }}>
          {["Tümü","Okunmamış","Uyarı","Bilgi","Başarı","Hata"].map(f => (
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
        {filtered.length === 0 ? (
          <div style={{ padding: "60px 20px", textAlign: "center" }}>
            <Icon name="bell" size={40} color="var(--text-tertiary)" />
            <div style={{ fontSize: 14, color: "var(--text-secondary)", marginTop: 14, fontWeight: 500 }}>Bildirim yok</div>
            <div style={{ fontSize: 11, color: "var(--text-tertiary)", marginTop: 4 }}>Bu filtrede gösterilecek bildirim bulunamadı</div>
          </div>
        ) : (
          <div style={{ background: "var(--surface-white)" }}>
            {filtered.map((n, i) => (
              <div key={n.id} style={{
                padding: "14px 16px",
                borderBottom: i < filtered.length - 1 ? "1px solid var(--surface-divider)" : "none",
                background: !n.read ? "rgba(26,58,92,0.03)" : "transparent",
                borderLeft: !n.read ? "3px solid var(--navy)" : "3px solid transparent",
                cursor: "pointer",
              }}>
                <div style={{ display: "flex", alignItems: "flex-start", gap: 12 }}>
                  <div style={{
                    width: 32, height: 32, borderRadius: 8,
                    background: `${notifColor(n.kind)}14`,
                    display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0,
                  }}>
                    <Icon name={notifIcon(n.kind)} size={15} color={notifColor(n.kind)} />
                  </div>
                  <div style={{ flex: 1, minWidth: 0 }}>
                    <div style={{ display: "flex", justifyContent: "space-between", alignItems: "baseline", gap: 8, marginBottom: 3 }}>
                      <div style={{ fontSize: 13, fontWeight: !n.read ? 500 : 400, color: "var(--text-primary)" }}>{n.title}</div>
                      <div style={{ fontSize: 10, color: "var(--text-tertiary)", whiteSpace: "nowrap" }}>{n.when}</div>
                    </div>
                    <div style={{ fontSize: 12, color: "var(--text-secondary)", lineHeight: 1.4 }}>{n.body}</div>
                  </div>
                  {!n.read && <div style={{ width: 8, height: 8, borderRadius: "50%", background: "var(--navy)", marginTop: 6 }} />}
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
      <BottomNav active="more" />
      {drawer && <AppDrawer open={drawer} onClose={() => setDrawer(false)} />}
    </div>
  );
}

Object.assign(window, { LocationListScreen, LocationDetailScreen, NotificationsScreen });
