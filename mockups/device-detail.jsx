// Cihaz Detay — 2 varyasyon, 4 tab: Genel / Donanım / Zimmetler / Geçmiş

function DeviceDetailHeader({ d, onBack, variant }) {
  const tone = statusTone(d.status);
  return (
    <div style={{ background: "var(--navy)", color: "#fff", padding: "14px 16px 18px" }}>
      <div style={{ display: "flex", alignItems: "flex-start", gap: 10 }}>
        <button onClick={onBack} style={{
          width: 36, height: 36, borderRadius: 8, background: "rgba(255,255,255,0.10)",
          border: "none", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center",
        }}><Icon name="chevronLeft" size={18} color="#fff" /></button>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontSize: 10, fontWeight: 500, letterSpacing: 1.4, color: "rgba(255,255,255,0.6)", textTransform: "uppercase" }}>
            {d.type} · {d.code}
          </div>
          <div style={{ fontSize: 19, fontWeight: 500, marginTop: 4, letterSpacing: -0.2 }}>{d.name}</div>
          {variant === "A" && (
            <div style={{ marginTop: 8, display: "flex", alignItems: "center", gap: 8 }}>
              <Chip tone={tone}>{d.status}</Chip>
              {d.assignee && <span style={{ fontSize: 12, color: "rgba(255,255,255,0.75)" }}>→ {d.assignee}</span>}
            </div>
          )}
        </div>
        <button style={{ width: 36, height: 36, borderRadius: 8, background: "rgba(255,255,255,0.10)", border: "none", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center" }}>
          <Icon name="edit" size={16} color="#fff" />
        </button>
        <button style={{ width: 36, height: 36, borderRadius: 8, background: "rgba(255,255,255,0.10)", border: "none", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center" }}>
          <Icon name="more" size={16} color="#fff" />
        </button>
      </div>
      {variant === "B" && (
        <div style={{ marginTop: 14, display: "grid", gridTemplateColumns: "1fr 1fr 1fr", gap: 8 }}>
          <div style={{ background: "rgba(255,255,255,0.08)", padding: "8px 10px", borderRadius: 6 }}>
            <div style={{ fontSize: 9, letterSpacing: 0.8, color: "rgba(255,255,255,0.6)", textTransform: "uppercase" }}>Durum</div>
            <div style={{ fontSize: 12, fontWeight: 500, marginTop: 2 }}>{d.status}</div>
          </div>
          <div style={{ background: "rgba(255,255,255,0.08)", padding: "8px 10px", borderRadius: 6 }}>
            <div style={{ fontSize: 9, letterSpacing: 0.8, color: "rgba(255,255,255,0.6)", textTransform: "uppercase" }}>Zimmetli</div>
            <div style={{ fontSize: 12, fontWeight: 500, marginTop: 2, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>{d.assignee || "—"}</div>
          </div>
          <div style={{ background: "rgba(255,255,255,0.08)", padding: "8px 10px", borderRadius: 6 }}>
            <div style={{ fontSize: 9, letterSpacing: 0.8, color: "rgba(255,255,255,0.6)", textTransform: "uppercase" }}>Lokasyon</div>
            <div style={{ fontSize: 12, fontWeight: 500, marginTop: 2, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>{d.loc}</div>
          </div>
        </div>
      )}
    </div>
  );
}

function GenelTab({ d, variant }) {
  return (
    <div style={{ padding: 16 }}>
      {variant === "A" ? (
        <div className="card">
          <div className="section-title" style={{ marginBottom: 10 }}>TEMEL BİLGİLER</div>
          <KV k="Marka" v={d.name.split(" ")[0]} />
          <KV k="Model" v={d.name} />
          <KV k="Seri No" v={d.serial} mono />
          <KV k="Demirbaş" v={d.code} mono />
          <KV k="Asset Tag" v={d.tag} mono />
          <KV k="Lokasyon" v={d.loc} />
          <KV k="Durum" v={<Chip tone={statusTone(d.status)}>{d.status}</Chip>} />
        </div>
      ) : (
        <>
          <div className="card" style={{ marginBottom: 10 }}>
            <div className="section-title" style={{ marginBottom: 10 }}>KİMLİK</div>
            <KV k="Seri No" v={d.serial} mono />
            <KV k="Demirbaş" v={d.code} mono />
            <KV k="Asset Tag" v={d.tag} mono />
          </div>
          <div className="card" style={{ marginBottom: 10 }}>
            <div className="section-title" style={{ marginBottom: 10 }}>SATIN ALMA & GARANTİ</div>
            <KV k="Satın Alma" v="12.03.2024" />
            <KV k="Tedarikçi" v="Dell Türkiye" />
            <KV k="Fatura No" v="FTR-2024-04812" mono />
            <KV k="Garanti Bitiş" v={<span style={{ color: "var(--warning)" }}>11.03.2027</span>} />
          </div>
        </>
      )}
    </div>
  );
}

function DonanimTab({ d }) {
  const hw = HARDWARE[d.id] || HARDWARE["D-0001"];
  return (
    <div style={{ padding: 16 }}>
      <div className="card">
        <div className="section-title" style={{ marginBottom: 10 }}>DONANIM BİLGİLERİ</div>
        <KV k="CPU" v={hw.cpu} />
        <KV k="RAM" v={hw.ram} />
        <KV k="Depolama" v={hw.storage} />
        <KV k="GPU" v={hw.gpu} />
        <KV k="Hostname" v={hw.hostname} mono />
        <KV k="OS" v={hw.os} />
        <KV k="MAC" v={hw.mac} mono />
        <KV k="IP" v={hw.ip} mono />
        <KV k="BIOS" v={hw.bios} />
        <KV k="Anakart" v={hw.motherboard} />
      </div>
    </div>
  );
}

function ZimmetlerTab({ d }) {
  const current = d.assignee ? { num: "ZMT-20260421-0142", person: d.assignee, start: "21.04.2026", active: true } : null;
  const past = [
    { num: "ZMT-20251108-0087", person: "Serkan Aydın",   start: "08.11.2025", end: "14.03.2026" },
    { num: "ZMT-20240514-0012", person: "Merve Çetin",     start: "14.05.2024", end: "07.11.2025" },
  ];
  return (
    <div style={{ padding: 16 }}>
      {current && (
        <>
          <div className="section-title" style={{ marginBottom: 8, paddingLeft: 4 }}>MEVCUT ZİMMET</div>
          <div className="card" style={{ borderLeft: "3px solid var(--success)", marginBottom: 16 }}>
            <div style={{ display: "flex", justifyContent: "space-between", marginBottom: 8 }}>
              <span style={{ fontSize: 11, color: "var(--text-secondary)", fontFamily: "ui-monospace, monospace" }}>{current.num}</span>
              <Chip tone="success">AKTİF</Chip>
            </div>
            <div style={{ fontSize: 15, fontWeight: 500, color: "var(--text-primary)", marginBottom: 4 }}>{current.person}</div>
            <div style={{ fontSize: 12, color: "var(--text-secondary)" }}>Başlangıç: {current.start}</div>
          </div>
        </>
      )}
      <div className="section-title" style={{ marginBottom: 8, paddingLeft: 4 }}>GEÇMİŞ ZİMMETLER</div>
      <div className="card" style={{ padding: "4px 16px" }}>
        {past.map((p, i) => (
          <div key={i} style={{ padding: "12px 0", borderBottom: i < past.length - 1 ? "1px solid var(--surface-divider)" : "none" }}>
            <div style={{ display: "flex", justifyContent: "space-between", marginBottom: 4 }}>
              <span style={{ fontSize: 11, color: "var(--text-tertiary)", fontFamily: "ui-monospace, monospace" }}>{p.num}</span>
              <span style={{ fontSize: 11, color: "var(--text-tertiary)" }}>{p.start} → {p.end}</span>
            </div>
            <div style={{ fontSize: 13, color: "var(--text-primary)" }}>{p.person}</div>
          </div>
        ))}
      </div>
    </div>
  );
}

function GecmisTab({ d }) {
  const [expanded, setExpanded] = React.useState(1);
  return (
    <div style={{ padding: 16 }}>
      <div className="section-title" style={{ marginBottom: 12, paddingLeft: 4 }}>DEĞİŞİKLİK GEÇMİŞİ</div>
      <div style={{ position: "relative", paddingLeft: 18 }}>
        <div style={{ position: "absolute", left: 5, top: 4, bottom: 4, width: 1, background: "var(--surface-divider)" }} />
        {AUDIT_LOG.map((log, i) => {
          const isExp = expanded === log.id;
          const dotColor = log.kind === "create" ? "var(--success)" : log.kind === "update" ? "var(--info)" : "var(--warning)";
          return (
            <div key={log.id} style={{ marginBottom: 10, position: "relative" }}>
              <div style={{
                position: "absolute", left: -18, top: 14,
                width: 11, height: 11, borderRadius: "50%",
                background: dotColor, border: "2px solid var(--surface-light)",
              }} />
              <div className="card" style={{ padding: "12px 14px" }}>
                <div onClick={() => log.changes && setExpanded(isExp ? null : log.id)} style={{ cursor: log.changes ? "pointer" : "default", display: "flex", alignItems: "center", gap: 10 }}>
                  <div style={{ flex: 1 }}>
                    <div style={{ fontSize: 13, fontWeight: 500, color: "var(--text-primary)", marginBottom: 3 }}>{log.action}</div>
                    <div style={{ fontSize: 11, color: "var(--text-secondary)" }}>
                      {log.user} · {log.when}
                    </div>
                  </div>
                  {log.changes && <Icon name={isExp ? "chevronUp" : "chevronDown"} size={16} color="var(--text-tertiary)" />}
                </div>
                {log.changes && isExp && (
                  <div style={{ marginTop: 12, paddingTop: 10, borderTop: "1px solid var(--surface-divider)" }}>
                    {log.changes.map((c, j) => (
                      <div key={j} style={{ marginBottom: 8 }}>
                        <div style={{ fontSize: 10, fontWeight: 500, letterSpacing: 1, color: "var(--text-secondary)", textTransform: "uppercase", marginBottom: 4 }}>{c.field}</div>
                        <div style={{ display: "flex", alignItems: "center", gap: 8, fontSize: 12, flexWrap: "wrap" }}>
                          <span style={{ color: "var(--error)", textDecoration: "line-through" }}>{c.before}</span>
                          <Icon name="arrowRight" size={12} color="var(--text-tertiary)" />
                          <span style={{ color: "var(--success)", fontWeight: 500 }}>{c.after}</span>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}

function DeviceDetailScreen({ device, variant = "A", onBack }) {
  const d = device || DEVICES[0];
  const [tab, setTab] = React.useState("Genel");
  const isAssigned = d.status === "Zimmetli";

  return (
    <div style={{ height: "100%", background: "var(--surface-light)", display: "flex", flexDirection: "column", position: "relative" }}>
      <DeviceDetailHeader d={d} onBack={onBack} variant={variant} />
      <TabBar tabs={["Genel","Donanım","Zimmetler","Geçmiş"]} active={tab} onChange={setTab} />
      <div style={{ flex: 1, overflow: "auto", paddingBottom: 92 }}>
        {tab === "Genel"     && <GenelTab d={d} variant={variant} />}
        {tab === "Donanım"   && <DonanimTab d={d} />}
        {tab === "Zimmetler" && <ZimmetlerTab d={d} />}
        {tab === "Geçmiş"    && <GecmisTab d={d} />}
      </div>
      {/* Floating action */}
      <div style={{
        position: "absolute", left: 16, right: 16, bottom: 24,
      }}>
        <button style={{
          width: "100%", height: 50,
          background: isAssigned ? "var(--warning)" : "var(--navy)",
          color: "#fff", border: "none", borderRadius: 10,
          fontFamily: "var(--font)", fontSize: 14, fontWeight: 500,
          cursor: "pointer", boxShadow: "0 6px 18px rgba(26,58,92,0.25)",
          display: "flex", alignItems: "center", justifyContent: "center", gap: 8,
        }}>
          <Icon name={isAssigned ? "upload" : "assign"} size={16} color="#fff" />
          {isAssigned ? "İade Et" : "Zimmetle"}
        </button>
      </div>
    </div>
  );
}

Object.assign(window, { DeviceDetailScreen });
