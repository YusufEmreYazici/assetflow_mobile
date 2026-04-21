// Dashboard — Varyasyon A (klasik 2x2 KPI grid + aktivite feed + hızlı işlemler)

function KpiCard({ label, value, delta, accent = "var(--navy)", bg = "var(--surface-light)", icon }) {
  return (
    <div style={{
      background: bg,
      borderRadius: 8,
      borderLeft: `3px solid ${accent}`,
      padding: "14px 14px 12px",
      display: "flex", flexDirection: "column", gap: 8,
      minHeight: 92,
    }}>
      <div style={{ display: "flex", alignItems: "flex-start", justifyContent: "space-between" }}>
        <div style={{
          fontSize: 10, fontWeight: 500, letterSpacing: 1,
          color: "var(--text-secondary)", textTransform: "uppercase",
        }}>{label}</div>
        {icon && (
          <div style={{ color: accent, opacity: 0.7 }}>
            <Icon name={icon} size={16} color="currentColor" />
          </div>
        )}
      </div>
      <div style={{
        fontSize: 24, fontWeight: 500, color: "var(--text-primary)",
        letterSpacing: -0.6, lineHeight: 1.1,
      }}>{value}</div>
      {delta && (
        <div style={{ fontSize: 10, color: "var(--text-secondary)", letterSpacing: 0.1 }}>
          {delta}
        </div>
      )}
    </div>
  );
}

function ActivityDot({ kind }) {
  const color = {
    success: "var(--success)", info: "var(--info)",
    warning: "var(--warning)", error: "var(--error)",
  }[kind] || "var(--text-tertiary)";
  return <div style={{ width: 8, height: 8, borderRadius: "50%", background: color, marginTop: 6, flexShrink: 0 }} />;
}

function ActivityTile({ item, isLast }) {
  return (
    <div style={{
      display: "flex", gap: 12, padding: "12px 0",
      borderBottom: isLast ? "none" : "1px solid var(--surface-divider)",
    }}>
      <ActivityDot kind={item.kind} />
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: "flex", justifyContent: "space-between", gap: 8, marginBottom: 3 }}>
          <div style={{
            fontSize: 10, fontWeight: 500, letterSpacing: 1,
            color: "var(--text-secondary)", textTransform: "uppercase",
          }}>{item.t}</div>
          <div style={{ fontSize: 11, color: "var(--text-tertiary)", flexShrink: 0 }}>{item.when}</div>
        </div>
        <div style={{ fontSize: 13, color: "var(--text-primary)", fontWeight: 500, marginBottom: 2, lineHeight: 1.35 }}>
          {item.main}
        </div>
        <div style={{ fontSize: 11, color: "var(--text-secondary)" }}>{item.detail}</div>
      </div>
    </div>
  );
}

function QuickAction({ icon, label, onClick, primary }) {
  return (
    <button onClick={onClick} style={{
      flex: 1,
      background: primary ? "var(--navy)" : "var(--surface-white)",
      color: primary ? "#fff" : "var(--navy)",
      border: primary ? "1px solid var(--navy)" : "1px solid var(--surface-input-border)",
      borderRadius: 8, padding: "12px 14px",
      display: "flex", alignItems: "center", justifyContent: "center", gap: 8,
      fontFamily: "var(--font)", fontSize: 13, fontWeight: 500,
      cursor: "pointer",
    }}>
      <Icon name={icon} size={16} color="currentColor" />
      {label}
    </button>
  );
}

function DashboardA({ onNav }) {
  const [tab, setTab] = React.useState("home");
  const [drawer, setDrawer] = React.useState(false);

  return (
    <div style={{ height: "100%", background: "var(--surface-light)", display: "flex", flexDirection: "column", position: "relative" }}>
      <div style={{ flex: 1, overflow: "auto", paddingBottom: 20 }}>
        <AppHeader onNotif={() => alert("Bildirimler")} onMenu={() => setDrawer(true)} />

        {/* KPIs */}
        <div style={{ padding: "20px 20px 0" }}>
          <SectionHeader>ÖZET</SectionHeader>
          <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 10 }}>
            <KpiCard label="Toplam Cihaz" value="158"   delta="▲ 3 bu ay"       accent="var(--navy)"    icon="device" />
            <KpiCard label="Aktif Zimmet" value="94"    delta="▲ 5 bu hafta"    accent="var(--success)" icon="assign" />
            <KpiCard label="Personel"     value="158"   delta="22 lokasyon"      accent="var(--text-secondary)" icon="people" />
            <KpiCard label="Uyarılar"     value="7"     delta="Garanti · 12 ay" accent="var(--warning)" bg="var(--warning-bg)" icon="warning" />
          </div>
        </div>

        {/* Quick Actions */}
        <div style={{ padding: "24px 20px 0" }}>
          <SectionHeader>HIZLI İŞLEMLER</SectionHeader>
          <div style={{ display: "flex", gap: 10 }}>
            <QuickAction icon="plus"   label="Yeni Cihaz" primary onClick={() => alert("Yeni cihaz")} />
            <QuickAction icon="assign" label="Zimmetle" onClick={() => alert("Zimmetle")} />
          </div>
        </div>

        {/* Activity */}
        <div style={{ padding: "24px 20px 0" }}>
          <SectionHeader right={
            <button style={{
              background: "transparent", border: "none", cursor: "pointer",
              font: "500 11px var(--font)", color: "var(--navy-light)", letterSpacing: 0.3,
            }}>TÜMÜ →</button>
          }>AKTİVİTE AKIŞI</SectionHeader>
          <div className="card" style={{ padding: "0 16px" }}>
            {ACTIVITY.slice(0, 5).map((a, i) => (
              <ActivityTile key={i} item={a} isLast={i === 4} />
            ))}
          </div>
        </div>

        {/* Warranty / warnings card */}
        <div style={{ padding: "24px 20px 0" }}>
          <SectionHeader>GARANTİ UYARILARI</SectionHeader>
          <div style={{
            background: "var(--warning-bg)", borderRadius: 8,
            padding: "14px 16px", display: "flex", gap: 12, alignItems: "flex-start",
            borderLeft: "3px solid var(--warning)",
          }}>
            <Icon name="warning" size={18} color="var(--warning)" />
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontSize: 13, fontWeight: 500, color: "var(--text-primary)", marginBottom: 4 }}>
                7 cihazın garantisi 60 gün içinde dolacak
              </div>
              <div style={{ fontSize: 11, color: "var(--text-secondary)", lineHeight: 1.5 }}>
                4 × Laptop · 2 × Monitor · 1 × Yazıcı — çoğu Mersin Limanı lokasyonunda
              </div>
            </div>
            <Icon name="chevronRight" size={16} color="var(--warning)" />
          </div>
        </div>
      </div>

      <BottomNav active={tab} onChange={setTab} onMore={() => setDrawer(true)} />
      <AppDrawer open={drawer} onClose={() => setDrawer(false)} current="home" onNavigate={k => alert("Navigate: " + k)} />
    </div>
  );
}

Object.assign(window, { DashboardA, KpiCard, ActivityTile, QuickAction });
