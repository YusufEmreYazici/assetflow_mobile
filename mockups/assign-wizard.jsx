// Zimmet Akışı — 4-step wizard: Kişi seç → Cihaz seç → Şartlar → Özet+İmza

function PersonRow({ p, selected, onSelect }) {
  const initials = p.name.split(" ").map(n => n[0]).slice(0,2).join("");
  return (
    <div onClick={() => onSelect(p)} style={{
      display: "flex", alignItems: "center", gap: 12, padding: "12px 16px",
      background: selected ? "rgba(26,58,92,0.06)" : "transparent",
      borderLeft: selected ? "3px solid var(--navy)" : "3px solid transparent",
      cursor: "pointer",
    }}>
      <div style={{ width: 40, height: 40, borderRadius: "50%", background: "var(--navy)", color: "#fff", display: "flex", alignItems: "center", justifyContent: "center", fontSize: 13, fontWeight: 500 }}>{initials}</div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 14, fontWeight: 500, color: "var(--text-primary)" }}>{p.name}</div>
        <div style={{ fontSize: 11, color: "var(--text-secondary)", marginTop: 2, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>{p.title} · {p.dept}</div>
      </div>
      {selected && <Icon name="check" size={16} color="var(--navy)" strokeWidth={2.5} />}
    </div>
  );
}

function DevicePickRow({ d, selected, onSelect }) {
  return (
    <div onClick={() => onSelect(d)} style={{
      display: "flex", alignItems: "center", gap: 12, padding: "12px 16px",
      background: selected ? "rgba(26,58,92,0.06)" : "transparent",
      borderLeft: selected ? "3px solid var(--navy)" : "3px solid transparent",
      cursor: "pointer",
    }}>
      <div style={{ width: 40, height: 40, borderRadius: 8, background: "var(--surface-light)", display: "flex", alignItems: "center", justifyContent: "center" }}>
        <Icon name={deviceIcon(d.type)} size={18} color="var(--navy)" />
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 13, fontWeight: 500, color: "var(--text-primary)", whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>{d.name}</div>
        <div style={{ fontSize: 10, color: "var(--text-tertiary)", fontFamily: "ui-monospace, monospace", marginTop: 2 }}>{d.code}</div>
      </div>
      {selected && <Icon name="check" size={16} color="var(--navy)" strokeWidth={2.5} />}
    </div>
  );
}

function AssignWizardScreen({ preselectedDevice, onBack, onComplete, startStep = 0 }) {
  const [step, setStep] = React.useState(startStep);
  const [person, setPerson] = React.useState(null);
  const [device, setDevice] = React.useState(preselectedDevice || null);
  const [search, setSearch] = React.useState("");
  const [terms, setTerms] = React.useState({
    start: "21.04.2026",
    duration: "Süresiz",
    personalUse: false,
    abroad: false,
    notes: "",
  });
  const [signed, setSigned] = React.useState(false);

  const availableDevices = DEVICES.filter(d => d.status === "Depoda");
  const filteredPeople = PEOPLE.filter(p => !search || p.name.toLowerCase().includes(search.toLowerCase()));

  const next = () => setStep(s => Math.min(3, s + 1));
  const prev = () => setStep(s => Math.max(0, s - 1));

  const canNext =
    (step === 0 && person) ||
    (step === 1 && device) ||
    (step === 2) ||
    (step === 3 && signed);

  const zimmetNo = "ZMT-20260421-0145";

  return (
    <div style={{ height: "100%", background: "var(--surface-light)", display: "flex", flexDirection: "column" }}>
      <PageHeader title="Zimmet Oluştur" back={onBack} subtitle={zimmetNo} />
      <StepIndicator steps={["Kişi","Cihaz","Şartlar","İmza"]} active={step} />

      <div style={{ flex: 1, overflow: "auto" }}>
        {/* Step 0 — Kişi Seçimi */}
        {step === 0 && (
          <div>
            <div style={{ padding: 16, background: "var(--surface-white)", borderBottom: "1px solid var(--surface-divider)" }}>
              <div style={{ position: "relative" }}>
                <div style={{ position: "absolute", left: 12, top: "50%", transform: "translateY(-50%)" }}>
                  <Icon name="search" size={14} color="var(--text-tertiary)" />
                </div>
                <input value={search} onChange={e => setSearch(e.target.value)} placeholder="İsim veya sicil ara..." className="input" style={{ paddingLeft: 36, fontSize: 13 }} />
              </div>
            </div>
            <div style={{ background: "var(--surface-white)" }}>
              {filteredPeople.map((p, i) => (
                <React.Fragment key={p.id}>
                  <PersonRow p={p} selected={person?.id === p.id} onSelect={setPerson} />
                  {i < filteredPeople.length - 1 && <div style={{ height: 1, background: "var(--surface-divider)", marginLeft: 68 }} />}
                </React.Fragment>
              ))}
            </div>
          </div>
        )}

        {/* Step 1 — Cihaz Seçimi */}
        {step === 1 && (
          <div>
            <div style={{ padding: "14px 16px", background: "var(--surface-white)", borderBottom: "1px solid var(--surface-divider)" }}>
              <div style={{ fontSize: 11, color: "var(--text-secondary)" }}>Kişi: <b style={{ color: "var(--text-primary)" }}>{person?.name}</b></div>
              <div style={{ fontSize: 10, color: "var(--text-tertiary)", marginTop: 3 }}>{availableDevices.length} depoda cihaz müsait</div>
            </div>
            <div style={{ background: "var(--surface-white)" }}>
              {availableDevices.map((d, i) => (
                <React.Fragment key={d.id}>
                  <DevicePickRow d={d} selected={device?.id === d.id} onSelect={setDevice} />
                  {i < availableDevices.length - 1 && <div style={{ height: 1, background: "var(--surface-divider)", marginLeft: 68 }} />}
                </React.Fragment>
              ))}
            </div>
          </div>
        )}

        {/* Step 2 — Şartlar */}
        {step === 2 && (
          <div style={{ padding: 16 }}>
            <div className="card">
              <div className="section-title" style={{ marginBottom: 12 }}>ZİMMET ŞARTLARI</div>
              <FormField label="BAŞLANGIÇ TARİHİ"><input className="input" value={terms.start} onChange={e => setTerms({...terms, start: e.target.value})} /></FormField>
              <FormField label="SÜRE"><Select value={terms.duration} onChange={v => setTerms({...terms, duration: v})} options={["Süresiz","6 ay","1 yıl","2 yıl","3 yıl"]} /></FormField>
              <div style={{ marginTop: 16 }}>
                <div className="label" style={{ marginBottom: 10 }}>KULLANIM İZİNLERİ</div>
                <label style={{ display: "flex", alignItems: "flex-start", gap: 10, padding: "10px 0", cursor: "pointer" }}>
                  <input type="checkbox" checked={terms.personalUse} onChange={e => setTerms({...terms, personalUse: e.target.checked})} style={{ marginTop: 2, accentColor: "var(--navy)" }} />
                  <div>
                    <div style={{ fontSize: 13, color: "var(--text-primary)" }}>Kişisel kullanıma izin</div>
                    <div style={{ fontSize: 11, color: "var(--text-secondary)", marginTop: 2 }}>İş dışı saatlerde kullanılabilir</div>
                  </div>
                </label>
                <div style={{ height: 1, background: "var(--surface-divider)" }} />
                <label style={{ display: "flex", alignItems: "flex-start", gap: 10, padding: "10px 0", cursor: "pointer" }}>
                  <input type="checkbox" checked={terms.abroad} onChange={e => setTerms({...terms, abroad: e.target.checked})} style={{ marginTop: 2, accentColor: "var(--navy)" }} />
                  <div>
                    <div style={{ fontSize: 13, color: "var(--text-primary)" }}>Yurt dışına çıkarılabilir</div>
                    <div style={{ fontSize: 11, color: "var(--text-secondary)", marginTop: 2 }}>Ek onay gerektirir (BT + İK)</div>
                  </div>
                </label>
              </div>
              <FormField label="NOTLAR">
                <textarea className="input" rows={3} value={terms.notes} onChange={e => setTerms({...terms, notes: e.target.value})} style={{ resize: "none", fontFamily: "var(--font)" }} placeholder="Opsiyonel..." />
              </FormField>
            </div>
          </div>
        )}

        {/* Step 3 — Özet + İmza */}
        {step === 3 && (
          <div style={{ padding: 16 }}>
            <div className="card" style={{ marginBottom: 12 }}>
              <div className="section-title" style={{ marginBottom: 10 }}>ÖZET</div>
              <KV k="Zimmet No" v={zimmetNo} mono />
              <KV k="Kişi" v={person?.name} />
              <KV k="Sicil" v={person?.sicil} mono />
              <KV k="Departman" v={person?.dept} />
            </div>
            <div className="card" style={{ marginBottom: 12 }}>
              <div className="section-title" style={{ marginBottom: 10 }}>CİHAZ</div>
              <KV k="Cihaz" v={device?.name} />
              <KV k="Demirbaş" v={device?.code} mono />
              <KV k="Seri No" v={device?.serial} mono />
            </div>
            <div className="card" style={{ marginBottom: 12 }}>
              <div className="section-title" style={{ marginBottom: 10 }}>ŞARTLAR</div>
              <KV k="Başlangıç" v={terms.start} />
              <KV k="Süre" v={terms.duration} />
              <KV k="Kişisel Kullanım" v={terms.personalUse ? "Evet" : "Hayır"} />
              <KV k="Yurt Dışı" v={terms.abroad ? "Evet" : "Hayır"} />
            </div>
            <div className="card" style={{ padding: 16 }}>
              <div className="section-title" style={{ marginBottom: 10 }}>DİJİTAL İMZA</div>
              <div onClick={() => setSigned(!signed)} style={{
                height: 120,
                background: signed ? "rgba(22,163,74,0.06)" : "var(--surface-light)",
                border: signed ? "2px solid var(--success)" : "2px dashed var(--surface-input-border)",
                borderRadius: 8,
                display: "flex", alignItems: "center", justifyContent: "center",
                flexDirection: "column", gap: 8,
                cursor: "pointer",
              }}>
                {signed ? (
                  <>
                    <div style={{ fontFamily: "'Brush Script MT', cursive", fontSize: 28, color: "var(--navy)", fontStyle: "italic" }}>
                      {person?.name}
                    </div>
                    <div style={{ fontSize: 10, color: "var(--success)", letterSpacing: 0.8, textTransform: "uppercase", fontWeight: 500 }}>
                      ✓ İmzalandı · 21.04.2026 14:32
                    </div>
                  </>
                ) : (
                  <>
                    <Icon name="edit" size={24} color="var(--text-tertiary)" />
                    <div style={{ fontSize: 12, color: "var(--text-secondary)" }}>İmzalamak için dokunun</div>
                  </>
                )}
              </div>
              {signed && (
                <div style={{ fontSize: 10, color: "var(--text-tertiary)", marginTop: 10, lineHeight: 1.5 }}>
                  KVKK gereği imza verisi şifreli saklanır. Zimmet PDF'i belge sistemine eklenecektir.
                </div>
              )}
            </div>
          </div>
        )}
      </div>

      <div style={{ display: "flex", gap: 10, padding: 16, background: "var(--surface-white)", borderTop: "1px solid var(--surface-divider)" }}>
        <button onClick={prev} disabled={step === 0} style={{ flex: 1, height: 46, background: "var(--surface-white)", color: step === 0 ? "var(--text-tertiary)" : "var(--navy)", border: "1px solid var(--surface-input-border)", borderRadius: 8, cursor: step === 0 ? "not-allowed" : "pointer", fontFamily: "var(--font)", fontSize: 13, fontWeight: 500 }}>Geri</button>
        {step < 3 ? (
          <button onClick={next} disabled={!canNext} style={{ flex: 1, height: 46, background: canNext ? "var(--navy)" : "var(--surface-divider)", color: "#fff", border: "none", borderRadius: 8, cursor: canNext ? "pointer" : "not-allowed", fontFamily: "var(--font)", fontSize: 13, fontWeight: 500 }}>İleri</button>
        ) : (
          <button onClick={() => onComplete && onComplete({ person, device, terms })} disabled={!signed} style={{ flex: 1, height: 46, background: signed ? "var(--success)" : "var(--surface-divider)", color: "#fff", border: "none", borderRadius: 8, cursor: signed ? "pointer" : "not-allowed", fontFamily: "var(--font)", fontSize: 13, fontWeight: 500 }}>Onayla ve Gönder</button>
        )}
      </div>
    </div>
  );
}

Object.assign(window, { AssignWizardScreen });
