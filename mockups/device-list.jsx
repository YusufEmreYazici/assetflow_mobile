// Cihaz Listesi — search + filter chips + kart liste + FAB

function DeviceRow({ d, onClick }) {
  const tone = statusTone(d.status);
  return (
    <button onClick={() => onClick && onClick(d)} style={{
      width: "100%", background: "var(--surface-white)", border: "none",
      borderBottom: "1px solid var(--surface-divider)", cursor: "pointer",
      padding: "14px 16px", display: "flex", alignItems: "center", gap: 12,
      textAlign: "left",
    }}>
      <div style={{
        width: 40, height: 40, borderRadius: 8,
        background: "var(--surface-light)", color: "var(--navy)",
        display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0,
      }}>
        <Icon name={typeIconName(d.type)} size={20} color="var(--navy)" />
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: "flex", alignItems: "center", gap: 6, marginBottom: 3 }}>
          <div style={{ fontSize: 14, fontWeight: 500, color: "var(--text-primary)", whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis", flex: 1 }}>
            {d.name}
          </div>
          <Chip tone={tone}>{d.status}</Chip>
        </div>
        <div style={{ fontSize: 11, color: "var(--text-secondary)", display: "flex", gap: 6, alignItems: "center" }}>
          <span>{d.code}</span>
          <span style={{ color: "var(--text-tertiary)" }}>·</span>
          <span>{d.assignee || "Atanmamış"}</span>
        </div>
      </div>
      <Icon name="chevronRight" size={16} color="var(--text-tertiary)" />
    </button>
  );
}

function DeviceListScreen({ onOpenDevice }) {
  const [q, setQ] = React.useState("");
  const [filter, setFilter] = React.useState("Tümü");
  const [drawer, setDrawer] = React.useState(false);
  const [tab, setTab] = React.useState("devices");

  const filtered = DEVICES.filter(d => {
    if (filter !== "Tümü" && d.status !== filter) return false;
    if (q && !(`${d.name} ${d.code} ${d.assignee || ""}`).toLowerCase().includes(q.toLowerCase())) return false;
    return true;
  });

  return (
    <div style={{ height: "100%", background: "var(--surface-light)", display: "flex", flexDirection: "column", position: "relative" }}>
      <div style={{ flex: 1, overflow: "auto", paddingBottom: 20 }}>
        <PageHeader title="Cihazlar" subtitle={`${filtered.length} CİHAZ`} back={() => setDrawer(true)}
          action={
            <button style={{
              width: 36, height: 36, borderRadius: 8, background: "rgba(255,255,255,0.14)",
              border: "none", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center",
            }}>
              <Icon name="plus" size={18} color="#fff" />
            </button>
          }
        />

        {/* Search */}
        <div style={{ padding: "14px 16px 0" }}>
          <div style={{ position: "relative" }}>
            <div style={{ position: "absolute", left: 12, top: "50%", transform: "translateY(-50%)", color: "var(--text-tertiary)" }}>
              <Icon name="search" size={16} />
            </div>
            <input value={q} onChange={e => setQ(e.target.value)} placeholder="Cihaz, kod, personel ara…"
              className="input" style={{ paddingLeft: 38, paddingRight: 38, height: 40, fontSize: 13 }} />
            <button style={{
              position: "absolute", right: 4, top: 4, width: 32, height: 32, borderRadius: 6,
              background: "transparent", border: "none", cursor: "pointer",
              display: "flex", alignItems: "center", justifyContent: "center",
            }}>
              <Icon name="filter" size={16} color="var(--text-secondary)" />
            </button>
          </div>
        </div>

        {/* Filter chips */}
        <div style={{ padding: "12px 16px 0", display: "flex", gap: 6, overflowX: "auto" }}>
          {["Tümü","Zimmetli","Depoda","Bakımda","Emekli"].map(f => {
            const active = filter === f;
            return (
              <button key={f} onClick={() => setFilter(f)} style={{
                padding: "6px 12px", borderRadius: 16, whiteSpace: "nowrap",
                background: active ? "var(--navy)" : "var(--surface-white)",
                color: active ? "#fff" : "var(--text-secondary)",
                border: active ? "1px solid var(--navy)" : "1px solid var(--surface-input-border)",
                fontSize: 12, fontWeight: 500, cursor: "pointer",
              }}>{f}</button>
            );
          })}
        </div>

        {/* List */}
        <div style={{ padding: "14px 16px 0" }}>
          <div style={{ background: "var(--surface-white)", borderRadius: 8, overflow: "hidden" }}>
            {filtered.map(d => <DeviceRow key={d.id} d={d} onClick={onOpenDevice} />)}
            {filtered.length === 0 && (
              <div style={{ padding: "40px 20px", textAlign: "center", color: "var(--text-secondary)", fontSize: 13 }}>
                Sonuç bulunamadı.
              </div>
            )}
          </div>
        </div>
      </div>

      {/* FAB */}
      <button style={{
        position: "absolute", right: 18, bottom: 86,
        width: 52, height: 52, borderRadius: 14, background: "var(--navy)",
        border: "none", cursor: "pointer", color: "#fff",
        display: "flex", alignItems: "center", justifyContent: "center",
        boxShadow: "0 6px 18px rgba(26,58,92,0.35)",
      }}>
        <Icon name="plus" size={22} color="#fff" strokeWidth={2} />
      </button>

      <BottomNav active={tab} onChange={setTab} onMore={() => setDrawer(true)} />
      <AppDrawer open={drawer} onClose={() => setDrawer(false)} current="devices" onNavigate={() => setDrawer(false)} />
    </div>
  );
}

Object.assign(window, { DeviceListScreen, DeviceRow });
