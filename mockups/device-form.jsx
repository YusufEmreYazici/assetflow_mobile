// Cihaz Ekle/Düzenle — 4 step wizard

function StepIndicator({ steps, active }) {
  return (
    <div style={{ display: "flex", alignItems: "center", padding: "16px 20px", background: "var(--surface-white)", borderBottom: "1px solid var(--surface-divider)" }}>
      {steps.map((s, i) => {
        const done = i < active;
        const cur = i === active;
        return (
          <React.Fragment key={s}>
            <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 4 }}>
              <div style={{
                width: 26, height: 26, borderRadius: "50%",
                background: done ? "var(--success)" : cur ? "var(--navy)" : "var(--surface-light)",
                color: done || cur ? "#fff" : "var(--text-tertiary)",
                display: "flex", alignItems: "center", justifyContent: "center",
                fontSize: 11, fontWeight: 500,
                border: cur ? "2px solid var(--navy-light)" : "none",
              }}>
                {done ? <Icon name="check" size={12} color="#fff" strokeWidth={2.5} /> : i + 1}
              </div>
              <div style={{ fontSize: 9, color: cur ? "var(--navy)" : "var(--text-tertiary)", fontWeight: cur ? 500 : 400, letterSpacing: 0.4, textTransform: "uppercase", whiteSpace: "nowrap" }}>{s}</div>
            </div>
            {i < steps.length - 1 && (
              <div style={{ flex: 1, height: 2, background: done ? "var(--success)" : "var(--surface-divider)", margin: "0 6px", marginBottom: 16 }} />
            )}
          </React.Fragment>
        );
      })}
    </div>
  );
}

function FormField({ label, children, hint }) {
  return (
    <div style={{ marginBottom: 14 }}>
      <label className="label" style={{ display: "block", marginBottom: 6 }}>{label}</label>
      {children}
      {hint && <div style={{ fontSize: 10, color: "var(--text-tertiary)", marginTop: 4 }}>{hint}</div>}
    </div>
  );
}

function Select({ value, onChange, options }) {
  return (
    <select value={value} onChange={e => onChange(e.target.value)} className="input" style={{ fontSize: 13, appearance: "none", backgroundImage: "url(\"data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='%236B7A8C' stroke-width='2'><path d='M5 9l7 7 7-7'/></svg>\")", backgroundRepeat: "no-repeat", backgroundPosition: "right 12px center", paddingRight: 32 }}>
      {options.map(o => <option key={o} value={o}>{o}</option>)}
    </select>
  );
}

function DeviceFormScreen({ onBack, onSaved }) {
  const [step, setStep] = React.useState(0);
  const [data, setData] = React.useState({
    name: "", brand: "Dell", model: "", serial: "", code: "GVN-LPT-", type: "Laptop",
    cpu: "", ram: "16 GB", storage: "512 GB NVMe",
    purchase: "21.04.2026", supplier: "Dell Türkiye", invoice: "", warranty: "36 ay",
    loc: "Ankara Genel Müdürlük", notes: "",
  });
  const set = (k, v) => setData(d => ({ ...d, [k]: v }));

  const next = () => setStep(s => Math.min(3, s + 1));
  const prev = () => setStep(s => Math.max(0, s - 1));

  return (
    <div style={{ height: "100%", background: "var(--surface-light)", display: "flex", flexDirection: "column" }}>
      <PageHeader title="Yeni Cihaz" back={onBack} subtitle="CİHAZ FORMU" />
      <StepIndicator steps={["Temel","Donanım","Alım","Lokasyon"]} active={step} />

      <div style={{ flex: 1, overflow: "auto", padding: 16 }}>
        {step === 0 && (
          <div className="card">
            <div className="section-title" style={{ marginBottom: 12 }}>TEMEL BİLGİLER</div>
            <FormField label="CİHAZ TİPİ">
              <Select value={data.type} onChange={v => set("type", v)} options={["Laptop","Masaüstü","Monitor","Yazıcı","Telefon","Tablet","Sunucu","Ağ Cihazı","Diğer"]} />
            </FormField>
            <FormField label="MARKA">
              <Select value={data.brand} onChange={v => set("brand", v)} options={["Dell","HP","Lenovo","Apple","Samsung","LG","Cisco","Diğer"]} />
            </FormField>
            <FormField label="MODEL">
              <input className="input" value={data.model} onChange={e => set("model", e.target.value)} placeholder="örn. Latitude 5540" />
            </FormField>
            <FormField label="SERİ NO">
              <input className="input" value={data.serial} onChange={e => set("serial", e.target.value)} placeholder="CN-0RJ2H4-..." />
            </FormField>
            <FormField label="DEMİRBAŞ KODU" hint="GVN + Tip + 4 hane">
              <input className="input" value={data.code} onChange={e => set("code", e.target.value)} style={{ fontFamily: "ui-monospace, monospace" }} />
            </FormField>
          </div>
        )}
        {step === 1 && (
          <div className="card">
            <div className="section-title" style={{ marginBottom: 12 }}>DONANIM BİLGİLERİ</div>
            <FormField label="CPU"><input className="input" value={data.cpu} onChange={e => set("cpu", e.target.value)} placeholder="Intel Core i7-1365U" /></FormField>
            <FormField label="RAM"><Select value={data.ram} onChange={v => set("ram", v)} options={["8 GB","16 GB","32 GB","64 GB","128 GB"]} /></FormField>
            <FormField label="DEPOLAMA"><Select value={data.storage} onChange={v => set("storage", v)} options={["256 GB NVMe","512 GB NVMe","1 TB NVMe","2 TB NVMe"]} /></FormField>
            <FormField label="HOSTNAME"><input className="input" placeholder="GVN-LPT-0142" style={{ fontFamily: "ui-monospace, monospace" }} /></FormField>
            <FormField label="OS"><Select value="Windows 11 Pro" onChange={() => {}} options={["Windows 11 Pro","Windows 10 Pro","macOS Sonoma","Linux Ubuntu","Diğer"]} /></FormField>
          </div>
        )}
        {step === 2 && (
          <div className="card">
            <div className="section-title" style={{ marginBottom: 12 }}>SATIN ALMA & GARANTİ</div>
            <FormField label="SATIN ALMA TARİHİ"><input className="input" value={data.purchase} onChange={e => set("purchase", e.target.value)} /></FormField>
            <FormField label="TEDARİKÇİ"><input className="input" value={data.supplier} onChange={e => set("supplier", e.target.value)} /></FormField>
            <FormField label="FATURA NO"><input className="input" value={data.invoice} onChange={e => set("invoice", e.target.value)} placeholder="FTR-2026-..." style={{ fontFamily: "ui-monospace, monospace" }} /></FormField>
            <FormField label="GARANTİ SÜRESİ"><Select value={data.warranty} onChange={v => set("warranty", v)} options={["12 ay","24 ay","36 ay","48 ay","60 ay"]} /></FormField>
          </div>
        )}
        {step === 3 && (
          <div className="card">
            <div className="section-title" style={{ marginBottom: 12 }}>LOKASYON & NOTLAR</div>
            <FormField label="LOKASYON"><Select value={data.loc} onChange={v => set("loc", v)} options={LOCATIONS} /></FormField>
            <FormField label="DURUM"><Select value="Depoda" onChange={() => {}} options={["Depoda","Aktif","Bakımda"]} /></FormField>
            <FormField label="NOTLAR">
              <textarea className="input" value={data.notes} onChange={e => set("notes", e.target.value)} rows={4} placeholder="Opsiyonel notlar..." style={{ resize: "none", fontFamily: "var(--font)" }} />
            </FormField>
          </div>
        )}
      </div>

      <div style={{ display: "flex", gap: 10, padding: 16, background: "var(--surface-white)", borderTop: "1px solid var(--surface-divider)" }}>
        <button onClick={prev} disabled={step === 0} style={{ flex: 1, height: 46, background: "var(--surface-white)", color: step === 0 ? "var(--text-tertiary)" : "var(--navy)", border: "1px solid var(--surface-input-border)", borderRadius: 8, cursor: step === 0 ? "not-allowed" : "pointer", fontFamily: "var(--font)", fontSize: 13, fontWeight: 500 }}>Geri</button>
        {step < 3 ? (
          <button onClick={next} style={{ flex: 1, height: 46, background: "var(--navy)", color: "#fff", border: "none", borderRadius: 8, cursor: "pointer", fontFamily: "var(--font)", fontSize: 13, fontWeight: 500 }}>İleri</button>
        ) : (
          <button onClick={() => onSaved && onSaved(data)} style={{ flex: 1, height: 46, background: "var(--success)", color: "#fff", border: "none", borderRadius: 8, cursor: "pointer", fontFamily: "var(--font)", fontSize: 13, fontWeight: 500 }}>Kaydet</button>
        )}
      </div>
    </div>
  );
}

Object.assign(window, { DeviceFormScreen, StepIndicator, FormField, Select });
