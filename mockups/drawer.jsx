// AppDrawer — Enterprise Pro sol kayar menü
// Usage: <AppDrawer open={open} onClose={...} current="home" onNavigate={...} />

const DRAWER_MENU = [
  {
    section: "YÖNETİM", items: [
      { key: "home",       label: "Anasayfa",        icon: "home" },
      { key: "devices",    label: "Cihazlar",        icon: "device",  badge: 158 },
      { key: "people",     label: "Personel",        icon: "people",  badge: 158 },
      { key: "assign",     label: "Zimmetler",       icon: "assign",  badge: "94 aktif" },
      { key: "returns",    label: "İade İşlemleri",  icon: "upload" },
      { key: "locations",  label: "Lokasyonlar",     icon: "flow",    badge: 22 },
    ],
  },
  {
    section: "RAPORLAR", items: [
      { key: "dashboard",  label: "Dashboard",       icon: "reports" },
      { key: "rep-device", label: "Cihaz Raporları", icon: "reports" },
      { key: "rep-assign", label: "Zimmet Raporları",icon: "reports" },
      { key: "export",     label: "Excel Export",    icon: "download" },
      { key: "audit",      label: "Audit Log",       icon: "clock" },
    ],
  },
  {
    section: "SİSTEM", items: [
      { key: "notif",      label: "Bildirimler",     icon: "bell",   badge: 3, badgeTone: "error" },
      { key: "sap",        label: "SAP Senkron.",    icon: "refresh" },
      { key: "settings",   label: "Ayarlar",         icon: "settings" },
      { key: "profile",    label: "Profilim",        icon: "people" },
      { key: "security",   label: "Güvenlik & Şifre",icon: "lock" },
    ],
  },
  {
    section: "YARDIM", items: [
      { key: "help",       label: "Yardım & Destek", icon: "inbox" },
      { key: "guide",      label: "Kullanım Kılavuzu", icon: "edit" },
      { key: "feedback",   label: "Geri Bildirim",   icon: "share" },
      { key: "about",      label: "Hakkında",        icon: "warning" },
    ],
  },
];

function DrawerMenuItem({ item, active, onClick }) {
  return (
    <button onClick={() => onClick && onClick(item.key)} style={{
      width: "100%", minHeight: 48,
      background: active ? "rgba(70,112,168,0.10)" : "transparent",
      borderLeft: active ? "3px solid var(--navy)" : "3px solid transparent",
      border: "none", cursor: "pointer",
      display: "flex", alignItems: "center", gap: 14,
      padding: "10px 18px 10px 15px",
      color: active ? "var(--navy)" : "var(--text-primary)",
      fontFamily: "var(--font)", fontSize: 14,
      fontWeight: active ? 500 : 400,
      textAlign: "left",
    }}>
      <Icon name={item.icon} size={18} color={active ? "var(--navy)" : "var(--text-secondary)"} />
      <span style={{ flex: 1 }}>{item.label}</span>
      {item.badge !== undefined && (
        <span style={{
          height: 20, padding: "0 8px", borderRadius: 10,
          background: item.badgeTone === "error" ? "var(--error)" : (active ? "var(--navy)" : "var(--surface-light)"),
          color: item.badgeTone === "error" ? "#fff" : (active ? "#fff" : "var(--text-secondary)"),
          fontSize: 10, fontWeight: 500, letterSpacing: 0.2,
          display: "inline-flex", alignItems: "center",
        }}>{item.badge}</span>
      )}
    </button>
  );
}

function AppDrawer({ open, onClose, current = "home", onNavigate, user = "Zeynep Aksoy", email = "zeynep.aksoy@guvenok.com.tr", role = "IT Specialist", company = "GÜVENOK Lojistik" }) {
  if (!open) return null;
  const initials = user.split(" ").map(s => s[0]).slice(0, 2).join("");

  const handleNav = (key) => {
    onNavigate && onNavigate(key);
    onClose && onClose();
  };

  return (
    <div style={{
      position: "absolute", inset: 0, zIndex: 100,
      display: "flex",
    }}>
      {/* Drawer panel */}
      <div style={{
        width: "82%", maxWidth: 320, height: "100%",
        background: "var(--surface-white)",
        display: "flex", flexDirection: "column",
        boxShadow: "4px 0 24px rgba(10,20,40,0.2)",
        animation: "drawer-in 220ms cubic-bezier(0.2, 0.8, 0.2, 1)",
      }}>
        {/* Profile header */}
        <div style={{
          background: "var(--navy)", color: "#fff",
          padding: "50px 20px 20px",
        }}>
          <div style={{ display: "flex", alignItems: "center", gap: 14, marginBottom: 14 }}>
            <div style={{
              width: 60, height: 60, borderRadius: 10,
              background: "rgba(255,255,255,0.14)",
              display: "flex", alignItems: "center", justifyContent: "center",
              fontSize: 22, fontWeight: 500, letterSpacing: 0.5,
            }}>{initials}</div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontSize: 17, fontWeight: 500, letterSpacing: -0.1 }}>{user}</div>
              <div style={{ fontSize: 12, color: "rgba(255,255,255,0.65)", marginTop: 2, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>
                {email}
              </div>
            </div>
            <button onClick={onClose} style={{
              width: 32, height: 32, borderRadius: 8, background: "rgba(255,255,255,0.10)",
              border: "none", cursor: "pointer",
              display: "flex", alignItems: "center", justifyContent: "center",
            }}>
              <Icon name="close" size={16} color="#fff" />
            </button>
          </div>
          <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
            <span style={{
              padding: "3px 8px", borderRadius: 4,
              background: "rgba(255,255,255,0.18)",
              fontSize: 10, fontWeight: 500, letterSpacing: 0.8, textTransform: "uppercase",
            }}>{role}</span>
            <span style={{ fontSize: 11, color: "rgba(255,255,255,0.6)" }}>· {company}</span>
          </div>
        </div>

        {/* Menu body */}
        <div style={{ flex: 1, overflow: "auto", paddingBottom: 8 }}>
          {DRAWER_MENU.map((section, si) => (
            <div key={section.section} style={{ paddingTop: si === 0 ? 14 : 8 }}>
              <div style={{
                padding: "10px 18px 8px",
                fontSize: 10, fontWeight: 500, letterSpacing: 1.4,
                color: "var(--text-tertiary)", textTransform: "uppercase",
              }}>{section.section}</div>
              {section.items.map(item => (
                <DrawerMenuItem
                  key={item.key} item={item}
                  active={item.key === current}
                  onClick={handleNav}
                />
              ))}
              {si < DRAWER_MENU.length - 1 && (
                <div style={{ height: 1, background: "var(--surface-light)", margin: "8px 0" }} />
              )}
            </div>
          ))}
        </div>

        {/* Footer — logout + version */}
        <div style={{ borderTop: "1px solid var(--surface-light)", padding: "6px 0" }}>
          <button onClick={() => handleNav("logout")} style={{
            width: "100%", minHeight: 48, padding: "10px 18px",
            background: "transparent", border: "none", cursor: "pointer",
            display: "flex", alignItems: "center", gap: 14,
            color: "var(--error)", fontFamily: "var(--font)", fontSize: 14, fontWeight: 500,
            textAlign: "left",
          }}>
            <Icon name="arrowLeft" size={18} color="var(--error)" />
            <span style={{ flex: 1 }}>Çıkış Yap</span>
          </button>
          <div style={{
            padding: "6px 18px 14px",
            fontSize: 10, color: "var(--text-tertiary)", letterSpacing: 0.3,
          }}>AssetFlow v2.4.1 · Build 2614</div>
        </div>
      </div>

      {/* Scrim */}
      <div onClick={onClose} style={{
        flex: 1, background: "rgba(10,20,40,0.35)",
        animation: "scrim-in 180ms ease",
      }} />
      <style>{`
        @keyframes drawer-in { from { transform: translateX(-100%); } to { transform: translateX(0); } }
        @keyframes scrim-in { from { opacity: 0; } to { opacity: 1; } }
      `}</style>
    </div>
  );
}

Object.assign(window, { AppDrawer, DRAWER_MENU });
