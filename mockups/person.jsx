// 09 Personel Liste + 10 Personel Detay

function PersonListScreen({ onBack, onOpenPerson }) {
  const [search, setSearch] = React.useState("");
  const [drawer, setDrawer] = React.useState(false);
  const filtered = PEOPLE.filter(p =>
    !search || p.name.toLowerCase().includes(search.toLowerCase()) || p.sicil.includes(search)
  );

  // group alphabetically
  const groups = {};
  [...filtered].sort((a,b) => a.name.localeCompare(b.name, "tr")).forEach(p => {
    const letter = p.name[0].toUpperCase();
    (groups[letter] = groups[letter] || []).push(p);
  });

  return (
    <div style={{ height: "100%", background: "var(--surface-light)", display: "flex", flexDirection: "column", position: "relative" }}>
      <div style={{ flex: 1, overflow: "auto", paddingBottom: 80 }}>
        <PageHeader title="Personel" subtitle={`${filtered.length} KAYIT`} back={() => setDrawer(true)}
          action={
            <button style={{ width: 36, height: 36, borderRadius: 8, background: "rgba(255,255,255,0.10)", border: "none", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center" }}>
              <Icon name="plus" size={16} color="#fff" />
            </button>
          } />
        <div style={{ padding: 12, background: "var(--surface-white)", borderBottom: "1px solid var(--surface-divider)" }}>
          <div style={{ position: "relative" }}>
            <div style={{ position: "absolute", left: 12, top: "50%", transform: "translateY(-50%)" }}>
              <Icon name="search" size={14} color="var(--text-tertiary)" />
            </div>
            <input value={search} onChange={e => setSearch(e.target.value)} placeholder="İsim, sicil, departman..." className="input" style={{ paddingLeft: 36, fontSize: 13 }} />
          </div>
        </div>

        {Object.keys(groups).sort().map(letter => (
          <div key={letter}>
            <div style={{ padding: "10px 16px 6px", fontSize: 10, fontWeight: 500, letterSpacing: 1.2, color: "var(--text-tertiary)", textTransform: "uppercase", background: "var(--surface-light)" }}>{letter}</div>
            <div style={{ background: "var(--surface-white)" }}>
              {groups[letter].map((p, i) => {
                const initials = p.name.split(" ").map(n => n[0]).slice(0,2).join("");
                return (
                  <div key={p.id} onClick={() => onOpenPerson && onOpenPerson(p)} style={{
                    display: "flex", alignItems: "center", gap: 12, padding: "12px 16px",
                    borderBottom: i < groups[letter].length - 1 ? "1px solid var(--surface-divider)" : "none",
                    cursor: "pointer",
                  }}>
                    <div style={{ width: 40, height: 40, borderRadius: "50%", background: "var(--navy)", color: "#fff", display: "flex", alignItems: "center", justifyContent: "center", fontSize: 13, fontWeight: 500 }}>{initials}</div>
                    <div style={{ flex: 1, minWidth: 0 }}>
                      <div style={{ fontSize: 14, fontWeight: 500, color: "var(--text-primary)" }}>{p.name}</div>
                      <div style={{ fontSize: 11, color: "var(--text-secondary)", marginTop: 2, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>{p.sicil} · {p.dept}</div>
                    </div>
                    <div style={{ display: "flex", flexDirection: "column", alignItems: "flex-end", gap: 3 }}>
                      <span style={{ fontSize: 14, fontWeight: 500, color: "var(--navy)" }}>{p.deviceCount || 0}</span>
                      <span style={{ fontSize: 8, color: "var(--text-tertiary)", letterSpacing: 0.8, textTransform: "uppercase" }}>cihaz</span>
                    </div>
                    <Icon name="chevronRight" size={14} color="var(--text-tertiary)" />
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

function PersonDetailScreen({ person, onBack }) {
  const p = person || PEOPLE[0];
  const [tab, setTab] = React.useState("Zimmetler");
  const initials = p.name.split(" ").map(n => n[0]).slice(0,2).join("");
  const myDevices = DEVICES.filter(d => d.assignee === p.name);

  return (
    <div style={{ height: "100%", background: "var(--surface-light)", display: "flex", flexDirection: "column" }}>
      {/* Header */}
      <div style={{ background: "var(--navy)", color: "#fff", padding: "12px 16px 20px" }}>
        <div style={{ display: "flex", alignItems: "center", gap: 10, marginBottom: 16 }}>
          <button onClick={onBack} style={{ width: 36, height: 36, borderRadius: 8, background: "rgba(255,255,255,0.10)", border: "none", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center" }}><Icon name="chevronLeft" size={18} color="#fff" /></button>
          <div style={{ flex: 1, fontSize: 10, fontWeight: 500, letterSpacing: 1.4, color: "rgba(255,255,255,0.6)", textTransform: "uppercase" }}>PERSONEL</div>
          <button style={{ width: 36, height: 36, borderRadius: 8, background: "rgba(255,255,255,0.10)", border: "none", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center" }}><Icon name="more" size={16} color="#fff" /></button>
        </div>
        <div style={{ display: "flex", alignItems: "center", gap: 14 }}>
          <div style={{ width: 60, height: 60, borderRadius: "50%", background: "rgba(255,255,255,0.15)", color: "#fff", display: "flex", alignItems: "center", justifyContent: "center", fontSize: 20, fontWeight: 500 }}>{initials}</div>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ fontSize: 19, fontWeight: 500, letterSpacing: -0.2 }}>{p.name}</div>
            <div style={{ fontSize: 12, color: "rgba(255,255,255,0.75)", marginTop: 3 }}>{p.title}</div>
            <div style={{ fontSize: 11, color: "rgba(255,255,255,0.6)", marginTop: 2, fontFamily: "ui-monospace, monospace" }}>{p.sicil} · {p.dept}</div>
          </div>
        </div>
        <div style={{ marginTop: 14, display: "grid", gridTemplateColumns: "1fr 1fr 1fr", gap: 8 }}>
          <div style={{ background: "rgba(255,255,255,0.08)", padding: "8px 10px", borderRadius: 6 }}>
            <div style={{ fontSize: 9, letterSpacing: 0.8, color: "rgba(255,255,255,0.6)", textTransform: "uppercase" }}>Zimmet</div>
            <div style={{ fontSize: 14, fontWeight: 500, marginTop: 2 }}>{myDevices.length}</div>
          </div>
          <div style={{ background: "rgba(255,255,255,0.08)", padding: "8px 10px", borderRadius: 6 }}>
            <div style={{ fontSize: 9, letterSpacing: 0.8, color: "rgba(255,255,255,0.6)", textTransform: "uppercase" }}>Lokasyon</div>
            <div style={{ fontSize: 11, fontWeight: 500, marginTop: 2, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>{p.loc || "Ankara GM"}</div>
          </div>
          <div style={{ background: "rgba(255,255,255,0.08)", padding: "8px 10px", borderRadius: 6 }}>
            <div style={{ fontSize: 9, letterSpacing: 0.8, color: "rgba(255,255,255,0.6)", textTransform: "uppercase" }}>Başlangıç</div>
            <div style={{ fontSize: 11, fontWeight: 500, marginTop: 2 }}>{p.start || "2021"}</div>
          </div>
        </div>
      </div>

      <TabBar tabs={["Zimmetler","İletişim","Geçmiş"]} active={tab} onChange={setTab} />

      <div style={{ flex: 1, overflow: "auto" }}>
        {tab === "Zimmetler" && (
          <div style={{ padding: 16 }}>
            {myDevices.length === 0 ? (
              <div style={{ padding: "40px 20px", textAlign: "center" }}>
                <Icon name="laptop" size={36} color="var(--text-tertiary)" />
                <div style={{ fontSize: 13, color: "var(--text-secondary)", marginTop: 12 }}>Aktif zimmet yok</div>
              </div>
            ) : (
              <>
                <div className="section-title" style={{ marginBottom: 10, paddingLeft: 4 }}>AKTİF ZİMMETLER ({myDevices.length})</div>
                <div className="card" style={{ padding: "4px 0" }}>
                  {myDevices.map((d, i) => (
                    <div key={d.id} style={{
                      display: "flex", alignItems: "center", gap: 12, padding: "12px 16px",
                      borderBottom: i < myDevices.length - 1 ? "1px solid var(--surface-divider)" : "none",
                    }}>
                      <div style={{ width: 36, height: 36, borderRadius: 8, background: "var(--surface-light)", display: "flex", alignItems: "center", justifyContent: "center" }}>
                        <Icon name={deviceIcon(d.type)} size={16} color="var(--navy)" />
                      </div>
                      <div style={{ flex: 1, minWidth: 0 }}>
                        <div style={{ fontSize: 13, fontWeight: 500, color: "var(--text-primary)", whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>{d.name}</div>
                        <div style={{ fontSize: 10, color: "var(--text-tertiary)", fontFamily: "ui-monospace, monospace", marginTop: 2 }}>{d.code}</div>
                      </div>
                      <Icon name="chevronRight" size={14} color="var(--text-tertiary)" />
                    </div>
                  ))}
                </div>
              </>
            )}
          </div>
        )}
        {tab === "İletişim" && (
          <div style={{ padding: 16 }}>
            <div className="card">
              <div className="section-title" style={{ marginBottom: 10 }}>İLETİŞİM BİLGİLERİ</div>
              <KV k="E-posta" v={p.email || `${p.name.toLowerCase().replace(/\s/g,".").replace(/ı/g,"i").replace(/ş/g,"s").replace(/ç/g,"c").replace(/ö/g,"o").replace(/ü/g,"u").replace(/ğ/g,"g")}@guvenok.com.tr`} />
              <KV k="Dahili" v={p.phone || "4812"} />
              <KV k="Cep" v="+90 5XX XXX XX XX" />
              <KV k="Yönetici" v={p.manager || "Murat Arslan"} />
            </div>
          </div>
        )}
        {tab === "Geçmiş" && (
          <div style={{ padding: 16 }}>
            <div className="section-title" style={{ marginBottom: 10, paddingLeft: 4 }}>ZİMMET GEÇMİŞİ</div>
            <div className="card" style={{ padding: "4px 16px" }}>
              {[
                { num: "ZMT-20260421-0142", dev: "Dell Latitude 5540", start: "21.04.2026", end: "—", active: true },
                { num: "ZMT-20240818-0056", dev: "iPhone 13 Pro",       start: "18.08.2024", end: "15.03.2026" },
                { num: "ZMT-20220301-0011", dev: "HP ProBook 450",      start: "01.03.2022", end: "17.08.2024" },
              ].map((z, i, arr) => (
                <div key={i} style={{ padding: "12px 0", borderBottom: i < arr.length - 1 ? "1px solid var(--surface-divider)" : "none" }}>
                  <div style={{ display: "flex", justifyContent: "space-between", marginBottom: 4 }}>
                    <span style={{ fontSize: 11, color: "var(--text-tertiary)", fontFamily: "ui-monospace, monospace" }}>{z.num}</span>
                    {z.active && <Chip tone="success">AKTİF</Chip>}
                  </div>
                  <div style={{ fontSize: 13, color: "var(--text-primary)", marginBottom: 3 }}>{z.dev}</div>
                  <div style={{ fontSize: 11, color: "var(--text-tertiary)" }}>{z.start} → {z.end}</div>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

Object.assign(window, { PersonListScreen, PersonDetailScreen });
