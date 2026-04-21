// Dashboard — Varyasyon B (daha yoğun / analytics-leaning)
// Farkları: hero KPI, horizontal KPI strip + mini bar chart, status breakdown,
// compact aktivite. Aynı tasarım sistemi, farklı bilgi yoğunluğu.

function MiniBarChart({ data, labels, accent = "var(--navy)" }) {
  const max = Math.max(...data);
  return (
    <div style={{ display: "flex", alignItems: "flex-end", gap: 4, height: 40 }}>
      {data.map((v, i) => (
        <div key={i} style={{ flex: 1, display: "flex", flexDirection: "column", gap: 4, alignItems: "center" }}>
          <div style={{
            width: "100%",
            height: `${(v / max) * 30}px`,
            background: i === data.length - 1 ? accent : "var(--surface-divider)",
            borderRadius: 2,
          }} />
          <div style={{ fontSize: 9, color: "var(--text-tertiary)" }}>{labels[i]}</div>
        </div>
      ))}
    </div>
  );
}

function StatusBar({ segments }) {
  const total = segments.reduce((a, s) => a + s.v, 0);
  return (
    <div>
      <div style={{
        display: "flex", width: "100%", height: 8,
        borderRadius: 4, overflow: "hidden", background: "var(--surface-light)",
      }}>
        {segments.map((s, i) => (
          <div key={i} style={{
            width: `${(s.v / total) * 100}%`,
            background: s.color,
          }} />
        ))}
      </div>
      <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "8px 16px", marginTop: 10 }}>
        {segments.map((s, i) => (
          <div key={i} style={{ display: "flex", alignItems: "center", gap: 8 }}>
            <div style={{ width: 8, height: 8, borderRadius: 2, background: s.color }} />
            <div style={{ fontSize: 11, color: "var(--text-secondary)", flex: 1 }}>{s.label}</div>
            <div style={{ fontSize: 12, color: "var(--text-primary)", fontWeight: 500 }}>{s.v}</div>
          </div>
        ))}
      </div>
    </div>
  );
}

function MetricStrip({ label, value, trend, accent = "var(--navy)" }) {
  return (
    <div style={{
      flex: 1, padding: "12px 14px",
      background: "var(--surface-white)", borderRadius: 8,
      borderTop: `2px solid ${accent}`,
      display: "flex", flexDirection: "column", gap: 4,
    }}>
      <div style={{
        fontSize: 9, fontWeight: 500, letterSpacing: 1,
        color: "var(--text-secondary)", textTransform: "uppercase",
      }}>{label}</div>
      <div style={{ fontSize: 20, fontWeight: 500, color: "var(--text-primary)", letterSpacing: -0.4 }}>{value}</div>
      {trend && <div style={{ fontSize: 10, color: "var(--text-tertiary)" }}>{trend}</div>}
    </div>
  );
}

function DashboardB({ onNav }) {
  const [tab, setTab] = React.useState("home");
  const [drawer, setDrawer] = React.useState(false);

  return (
    <div style={{ height: "100%", background: "var(--surface-light)", display: "flex", flexDirection: "column", position: "relative" }}>
      <div style={{ flex: 1, overflow: "auto", paddingBottom: 20 }}>
        <AppHeader onNotif={() => alert("Bildirimler")} onMenu={() => setDrawer(true)} />

        {/* Hero KPI — envanter sağlığı */}
        <div style={{ padding: "20px 20px 0" }}>
          <div style={{
            background: "var(--surface-white)", borderRadius: 8, padding: 16,
          }}>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: 14 }}>
              <div>
                <div style={{
                  fontSize: 10, fontWeight: 500, letterSpacing: 1,
                  color: "var(--text-secondary)", textTransform: "uppercase", marginBottom: 6,
                }}>ENVANTER DURUMU · NİSAN 2026</div>
                <div style={{ display: "flex", alignItems: "baseline", gap: 8 }}>
                  <span style={{ fontSize: 32, fontWeight: 500, color: "var(--navy)", letterSpacing: -0.8 }}>158</span>
                  <span style={{ fontSize: 12, color: "var(--text-secondary)" }}>toplam cihaz</span>
                </div>
              </div>
              <div style={{ display: "flex", flexDirection: "column", alignItems: "flex-end", gap: 2 }}>
                <div style={{
                  fontSize: 10, fontWeight: 500, letterSpacing: 0.6,
                  color: "var(--success)", background: "var(--success-bg)",
                  padding: "3px 8px", borderRadius: 4,
                }}>▲ 3 BU AY</div>
                <div style={{ fontSize: 10, color: "var(--text-tertiary)", marginTop: 4 }}>Son 6 ay</div>
                <div style={{ width: 90, marginTop: 2 }}>
                  <MiniBarChart data={[142, 147, 150, 152, 155, 158]} labels={["K","A","O","Ş","M","N"]} accent="var(--navy)" />
                </div>
              </div>
            </div>
            {/* Status segments */}
            <StatusBar segments={[
              { label: "Zimmetli", v: 94, color: "var(--success)" },
              { label: "Depoda",   v: 42, color: "var(--info)" },
              { label: "Bakımda",  v: 8,  color: "var(--warning)" },
              { label: "Emekli",   v: 14, color: "var(--text-tertiary)" },
            ]} />
          </div>
        </div>

        {/* Metric strip */}
        <div style={{ padding: "14px 20px 0" }}>
          <div style={{ display: "flex", gap: 10 }}>
            <MetricStrip label="Aktif Zimmet" value="94"  trend="▲ 5 bu hafta"  accent="var(--success)" />
            <MetricStrip label="Personel"     value="158" trend="22 lokasyon"    accent="var(--navy)" />
            <MetricStrip label="Uyarı"        value="7"   trend="Garanti · 60g"  accent="var(--warning)" />
          </div>
        </div>

        {/* Quick Actions */}
        <div style={{ padding: "20px 20px 0" }}>
          <SectionHeader>HIZLI İŞLEMLER</SectionHeader>
          <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr 1fr", gap: 8 }}>
            <QuickAction icon="plus"   label="Cihaz" primary />
            <QuickAction icon="assign" label="Zimmet" />
            <QuickAction icon="upload" label="İade" />
          </div>
        </div>

        {/* Activity — compact */}
        <div style={{ padding: "24px 20px 0" }}>
          <SectionHeader right={
            <button style={{
              background: "transparent", border: "none", cursor: "pointer",
              font: "500 11px var(--font)", color: "var(--navy-light)", letterSpacing: 0.3,
            }}>TÜMÜ →</button>
          }>SON HAREKETLER</SectionHeader>
          <div className="card" style={{ padding: "0 16px" }}>
            {ACTIVITY.slice(0, 4).map((a, i) => (
              <ActivityTile key={i} item={a} isLast={i === 3} />
            ))}
          </div>
        </div>

        {/* Lokasyon dağılımı */}
        <div style={{ padding: "24px 20px 0" }}>
          <SectionHeader>LOKASYON DAĞILIMI</SectionHeader>
          <div className="card">
            {[
              { loc: "Ankara Genel Müdürlük", v: 52, pct: 0.33 },
              { loc: "Mersin Limanı",          v: 38, pct: 0.24 },
              { loc: "İzmit Terminal",         v: 26, pct: 0.16 },
              { loc: "Aliağa Rafineri",        v: 18, pct: 0.11 },
              { loc: "Diğer (18 lokasyon)",    v: 24, pct: 0.16 },
            ].map((r, i) => (
              <div key={i} style={{ padding: "8px 0", borderBottom: i < 4 ? "1px solid var(--surface-divider)" : "none" }}>
                <div style={{ display: "flex", justifyContent: "space-between", marginBottom: 6 }}>
                  <span style={{ fontSize: 12, color: "var(--text-primary)" }}>{r.loc}</span>
                  <span style={{ fontSize: 12, color: "var(--text-secondary)", fontWeight: 500 }}>{r.v}</span>
                </div>
                <div style={{ height: 4, background: "var(--surface-light)", borderRadius: 2, overflow: "hidden" }}>
                  <div style={{ width: `${r.pct * 100}%`, height: "100%", background: "var(--navy)" }} />
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      <BottomNav active={tab} onChange={setTab} onMore={() => setDrawer(true)} />
      <AppDrawer open={drawer} onClose={() => setDrawer(false)} current="home" onNavigate={k => alert("Navigate: " + k)} />
    </div>
  );
}

Object.assign(window, { DashboardB, MiniBarChart, StatusBar, MetricStrip });
