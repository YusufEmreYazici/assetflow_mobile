// AssetFlow — minimal icon set
const ICON_PATHS = {
  device: "M4 5.5a1.5 1.5 0 0 1 1.5-1.5h13A1.5 1.5 0 0 1 20 5.5v9A1.5 1.5 0 0 1 18.5 16h-13A1.5 1.5 0 0 1 4 14.5v-9zM9 20h6M12 16v4",
  people: "M16 20v-1.5A3.5 3.5 0 0 0 12.5 15h-5A3.5 3.5 0 0 0 4 18.5V20M10 11.5A3.5 3.5 0 1 0 10 4.5a3.5 3.5 0 0 0 0 7zM20 20v-1.5a3.5 3.5 0 0 0-2.6-3.4M15 4.6a3.5 3.5 0 0 1 0 6.8",
  assign: "M7 6h10M7 12h7M7 18h5M15.5 16.5l2 2 3-3",
  bell: "M6 16V11a6 6 0 0 1 12 0v5l1.5 2h-15L6 16zM10 20a2 2 0 0 0 4 0",
  plus: "M12 5v14M5 12h14",
  search: "M11 18a7 7 0 1 0 0-14 7 7 0 0 0 0 14zM20 20l-4-4",
  filter: "M4 6h16M7 12h10M10 18h4",
  menu: "M4 7h16M4 12h16M4 17h16",
  chevronRight: "M9 5l7 7-7 7",
  chevronLeft: "M15 5l-7 7 7 7",
  chevronDown: "M5 9l7 7 7-7",
  chevronUp: "M5 15l7-7 7 7",
  close: "M6 6l12 12M18 6L6 18",
  check: "M5 12l5 5 9-10",
  arrowRight: "M4 12h16M14 6l6 6-6 6",
  arrowLeft: "M20 12H4M10 18l-6-6 6-6",
  dots: "M12 6h.01M12 12h.01M12 18h.01",
  edit: "M4 20h4l10-10-4-4L4 16v4zM14 6l4 4",
  trash: "M4 7h16M9 7V4h6v3M6 7l1 13h10l1-13",
  more: "M5 12h.01M12 12h.01M19 12h.01",
  home: "M4 11l8-7 8 7v9a1 1 0 0 1-1 1h-4v-6h-6v6H5a1 1 0 0 1-1-1v-9z",
  inbox: "M4 12v6a1 1 0 0 0 1 1h14a1 1 0 0 0 1-1v-6M4 12l2.5-7a1 1 0 0 1 .9-.6h9.2a1 1 0 0 1 .9.6L20 12M4 12h5l1 2h4l1-2h5",
  reports: "M4 20V10M10 20V4M16 20v-7M20 20H4",
  settings: "M12 9.5a2.5 2.5 0 1 0 0 5 2.5 2.5 0 0 0 0-5zM19.4 15a1.7 1.7 0 0 0 .3 1.9l.1.1a2 2 0 1 1-2.8 2.8l-.1-.1a1.7 1.7 0 0 0-1.9-.3 1.7 1.7 0 0 0-1 1.5V21a2 2 0 1 1-4 0v-.1a1.7 1.7 0 0 0-1.1-1.5 1.7 1.7 0 0 0-1.9.3l-.1.1a2 2 0 1 1-2.8-2.8l.1-.1a1.7 1.7 0 0 0 .3-1.9 1.7 1.7 0 0 0-1.5-1H3a2 2 0 1 1 0-4h.1a1.7 1.7 0 0 0 1.5-1.1 1.7 1.7 0 0 0-.3-1.9l-.1-.1a2 2 0 1 1 2.8-2.8l.1.1a1.7 1.7 0 0 0 1.9.3H9a1.7 1.7 0 0 0 1-1.5V3a2 2 0 1 1 4 0v.1a1.7 1.7 0 0 0 1 1.5 1.7 1.7 0 0 0 1.9-.3l.1-.1a2 2 0 1 1 2.8 2.8l-.1.1a1.7 1.7 0 0 0-.3 1.9V9a1.7 1.7 0 0 0 1.5 1H21a2 2 0 1 1 0 4h-.1a1.7 1.7 0 0 0-1.5 1z",
  eye: "M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12zM12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6z",
  eyeOff: "M4 4l16 16M10.5 7A7 7 0 0 1 12 7c6.5 0 10 7 10 7a18 18 0 0 1-2.6 3M6.6 6.6A18 18 0 0 0 2 12s3.5 7 10 7a8.5 8.5 0 0 0 3.3-.6M10 10a3 3 0 0 0 4 4",
  lock: "M6 10V8a6 6 0 0 1 12 0v2M5 10h14v10H5V10zM12 14v3",
  mail: "M3 6h18v12H3V6zM3 6l9 7 9-7",
  download: "M12 4v12M7 11l5 5 5-5M5 20h14",
  share: "M18 7a3 3 0 1 0 0-6 3 3 0 0 0 0 6zM6 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6zM18 23a3 3 0 1 0 0-6 3 3 0 0 0 0 6zM8.5 10.5l7-3M8.5 13.5l7 3",
  upload: "M12 20V8M7 13l5-5 5 5M5 4h14",
  clock: "M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18zM12 7v5l3 2",
  warning: "M12 3L2 20h20L12 3zM12 10v5M12 18v.01",
  refresh: "M20 12a8 8 0 1 1-2.3-5.6M20 4v5h-5",
  laptop: "M5 6h14v10H5V6zM3 18h18",
  monitor: "M4 5h16v11H4V5zM9 20h6M12 16v4",
  phone: "M8 3h8a1 1 0 0 1 1 1v16a1 1 0 0 1-1 1H8a1 1 0 0 1-1-1V4a1 1 0 0 1 1-1zM11 18h2",
  tablet: "M6 3h12a1 1 0 0 1 1 1v16a1 1 0 0 1-1 1H6a1 1 0 0 1-1-1V4a1 1 0 0 1 1-1zM11 18h2",
  printer: "M7 8V3h10v5M7 18H5a1 1 0 0 1-1-1v-7a1 1 0 0 1 1-1h14a1 1 0 0 1 1 1v7a1 1 0 0 1-1 1h-2M7 14h10v7H7v-7z",
  server: "M4 4h16v6H4V4zM4 14h16v6H4v-6zM7 7h.01M7 17h.01",
  router: "M4 12h16v6H4v-6zM7 15h.01M8 12V9a4 4 0 0 1 8 0v3",
  box: "M4 7l8-4 8 4v10l-8 4-8-4V7zM4 7l8 4 8-4M12 11v10",
  sun: "M12 4v2M12 18v2M4 12h2M18 12h2M6.3 6.3l1.4 1.4M16.3 16.3l1.4 1.4M6.3 17.7l1.4-1.4M16.3 7.7l1.4-1.4M12 16a4 4 0 1 0 0-8 4 4 0 0 0 0 8z",
  moon: "M20 14.5A8 8 0 0 1 9.5 4a8 8 0 1 0 10.5 10.5z",
  flow: "M5 5h4v4H5V5zM15 5h4v4h-4V5zM10 15h4v4h-4v-4zM9 7h6M7 9v4a2 2 0 0 0 2 2h2M17 9v4a2 2 0 0 1-2 2h-2",
};

function Icon({ name, size = 20, color = "currentColor", strokeWidth = 1.6, style = {} }) {
  const d = ICON_PATHS[name];
  if (!d) return null;
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" style={{ flexShrink: 0, ...style }}>
      <path d={d} stroke={color} strokeWidth={strokeWidth} strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

function typeIconName(type) {
  switch (type) {
    case "Laptop":     return "laptop";
    case "Masaüstü":   return "server";
    case "Monitor":    return "monitor";
    case "Yazıcı":     return "printer";
    case "Telefon":    return "phone";
    case "Tablet":     return "tablet";
    case "Sunucu":     return "server";
    case "Ağ Cihazı":  return "router";
    default:           return "box";
  }
}
function statusTone(status) {
  switch (status) {
    case "Zimmetli":   return "success";
    case "Depoda":     return "info";
    case "Bakımda":    return "warning";
    case "Emekli":     return "neutral";
    case "Kayıp":
    case "Arızalı":    return "error";
    default:           return "neutral";
  }
}
Object.assign(window, { Icon, typeIconName, statusTone });
