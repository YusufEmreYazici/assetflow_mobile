// Shared UI primitives (buttons, chips, section headers) + phone chrome tuned for AssetFlow

function Chip({ tone = "neutral", children, dot }) {
  return (
    <span className={`chip chip-${tone}`}>
      {dot && <span className="chip-dot" style={{ background: "currentColor" }} />}
      {children}
    </span>
  );
}

function SectionHeader({ children, right }) {
  return (
    <div style={{
      display: "flex", alignItems: "center", justifyContent: "space-between",
      padding: "0 20px", marginBottom: 10,
    }}>
      <div className="label">{children}</div>
      {right}
    </div>
  );
}

// Phone-local app header (Navy)
function AppHeader({ user = "Zeynep Aksoy", role = "IT Specialist · GÜVENOK", company = "ASSETFLOW", title = "IT Varlık Yönetimi", onNotif, onMenu, badge = true }) {
  const initials = user.split(" ").map(s => s[0]).slice(0, 2).join("");
  return (
    <div style={{
      background: "var(--navy)", color: "#fff",
      padding: "14px 20px 18px",
    }}>
      {/* top row */}
      <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 14 }}>
        <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
          {onMenu && (
            <button onClick={onMenu} style={{
              width: 36, height: 36, borderRadius: 8, background: "rgba(255,255,255,0.10)",
              border: "none", display: "flex", alignItems: "center", justifyContent: "center", cursor: "pointer",
            }}>
              <Icon name="menu" size={18} color="#fff" />
            </button>
          )}
          <div style={{
            width: 32, height: 32, borderRadius: 6,
            background: "rgba(255,255,255,0.14)",
            display: "flex", alignItems: "center", justifyContent: "center",
            font: "500 12px var(--font)", letterSpacing: 0.5,
          }}>{initials}</div>
          <div style={{ lineHeight: 1.2 }}>
            <div style={{ fontSize: 13, fontWeight: 500 }}>Hoş geldin, {user.split(" ")[0]}</div>
            <div style={{ fontSize: 11, color: "rgba(255,255,255,0.6)", marginTop: 2 }}>{role}</div>
          </div>
        </div>
        <button onClick={onNotif} style={{
          width: 36, height: 36, borderRadius: 8, background: "rgba(255,255,255,0.10)",
          border: "none", display: "flex", alignItems: "center", justifyContent: "center",
          position: "relative", cursor: "pointer",
        }}>
          <Icon name="bell" size={18} color="#fff" />
          {badge && <span style={{
            position: "absolute", top: 8, right: 8, width: 8, height: 8, borderRadius: "50%",
            background: "#E04545", border: "2px solid var(--navy)",
          }} />}
        </button>
      </div>
      {/* company + title */}
      <div style={{
        fontSize: 10, fontWeight: 500, letterSpacing: 1.4,
        color: "rgba(255,255,255,0.55)", textTransform: "uppercase",
      }}>{company}</div>
      <div style={{ fontSize: 22, fontWeight: 500, marginTop: 4, letterSpacing: -0.2 }}>
        {title}
      </div>
    </div>
  );
}

// Compact page header (non-dashboard screens)
function PageHeader({ title, back, action, subtitle }) {
  return (
    <div style={{
      background: "var(--navy)", color: "#fff",
      padding: "14px 16px 18px",
      display: "flex", alignItems: "flex-start", justifyContent: "space-between", gap: 12,
    }}>
      <div style={{ display: "flex", alignItems: "center", gap: 10, flex: 1, minWidth: 0 }}>
        {back && (
          <button onClick={back} style={{
            width: 36, height: 36, borderRadius: 8, background: "rgba(255,255,255,0.10)",
            border: "none", display: "flex", alignItems: "center", justifyContent: "center", cursor: "pointer",
          }}>
            <Icon name="chevronLeft" size={18} color="#fff" />
          </button>
        )}
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontSize: 19, fontWeight: 500, letterSpacing: -0.2, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>
            {title}
          </div>
          {subtitle && (
            <div style={{ fontSize: 11, color: "rgba(255,255,255,0.6)", marginTop: 2, letterSpacing: 0.2 }}>{subtitle}</div>
          )}
        </div>
      </div>
      {action}
    </div>
  );
}

// Bottom tab bar — 4 tabs + more (opens drawer)
function BottomNav({ active, onChange, onMore }) {
  const tabs = [
    { key: "home",    label: "Anasayfa", icon: "home" },
    { key: "devices", label: "Cihazlar", icon: "device" },
    { key: "people",  label: "Personel", icon: "people" },
    { key: "more",    label: "Daha Fazla", icon: "menu" },
  ];
  return (
    <div style={{
      background: "var(--navy)", color: "#fff",
      display: "flex", justifyContent: "space-around", alignItems: "stretch",
      padding: "8px 4px 10px",
      borderTop: "1px solid rgba(255,255,255,0.06)",
    }}>
      {tabs.map(t => {
        const isActive = t.key === active;
        return (
          <button key={t.key} onClick={() => {
              if (t.key === "more") { onMore && onMore(); return; }
              onChange && onChange(t.key);
            }}
            style={{
              flex: 1, background: "transparent", border: "none", cursor: "pointer",
              display: "flex", flexDirection: "column", alignItems: "center", gap: 4,
              color: isActive ? "#fff" : "rgba(255,255,255,0.5)",
              padding: "6px 2px",
            }}>
            <Icon name={t.icon} size={20} color="currentColor" strokeWidth={isActive ? 1.8 : 1.5} />
            <span style={{ fontSize: 10, fontWeight: isActive ? 500 : 400, letterSpacing: 0.1 }}>{t.label}</span>
          </button>
        );
      })}
    </div>
  );
}

// A thin sub-tab bar (used in Cihaz Detay)
function TabBar({ tabs, active, onChange }) {
  return (
    <div style={{
      display: "flex", background: "var(--surface-white)",
      borderBottom: "1px solid var(--surface-divider)", padding: "0 16px",
    }}>
      {tabs.map(t => {
        const isActive = t === active;
        return (
          <button key={t} onClick={() => onChange(t)} style={{
            background: "transparent", border: "none", cursor: "pointer",
            padding: "14px 12px 12px", flex: 1,
            color: isActive ? "var(--navy)" : "var(--text-secondary)",
            fontFamily: "var(--font)", fontSize: 13, fontWeight: 500,
            borderBottom: isActive ? "2px solid var(--navy)" : "2px solid transparent",
            marginBottom: -1,
          }}>{t}</button>
        );
      })}
    </div>
  );
}

// Small key-value row used in detail cards
function KV({ k, v, mono }) {
  return (
    <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", padding: "10px 0", gap: 16, borderBottom: "1px solid var(--surface-divider)" }}>
      <div style={{ fontSize: 12, color: "var(--text-secondary)", flexShrink: 0 }}>{k}</div>
      <div style={{ fontSize: 13, color: "var(--text-primary)", fontWeight: 500, textAlign: "right", fontFamily: mono ? "ui-monospace, SFMono-Regular, Menlo, monospace" : "var(--font)" }}>{v}</div>
    </div>
  );
}

// Container that looks like a phone — used outside iOS frame in some explorations
function PhoneShell({ children, theme = "light" }) {
  return (
    <div data-theme={theme} style={{
      width: 390, height: 844, borderRadius: 44, overflow: "hidden",
      background: "var(--surface-light)", boxShadow: "0 30px 80px rgba(10,20,40,0.25), 0 0 0 1px rgba(0,0,0,0.12)",
      display: "flex", flexDirection: "column", position: "relative",
    }}>
      {children}
    </div>
  );
}

Object.assign(window, { Chip, SectionHeader, AppHeader, PageHeader, BottomNav, TabBar, KV, PhoneShell });
