// Şifre sıfırlama akışı — 3 ekran: Forgot → Sent → ResetPassword

// ─── 02a Şifremi Unuttum ───
function ForgotPasswordScreen({ onBack, onSubmit }) {
  const [email, setEmail] = React.useState("");
  const [focus, setFocus] = React.useState(false);
  const [err, setErr] = React.useState(null);
  const [loading, setLoading] = React.useState(false);

  const submit = (e) => {
    e && e.preventDefault();
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      setErr("Geçerli bir e-posta adresi girin."); return;
    }
    setErr(null); setLoading(true);
    setTimeout(() => { setLoading(false); onSubmit && onSubmit(email); }, 700);
  };

  return (
    <div style={{ height: "100%", background: "var(--surface-white)", display: "flex", flexDirection: "column" }}>
      <PageHeader title="Şifre Sıfırlama" back={onBack} subtitle="ASSETFLOW" />
      <div style={{ flex: 1, overflow: "auto", padding: "28px 28px 40px" }}>
        <div style={{
          width: 48, height: 48, borderRadius: 10, background: "var(--info-bg)",
          display: "flex", alignItems: "center", justifyContent: "center", marginBottom: 20,
        }}>
          <Icon name="mail" size={22} color="var(--info)" />
        </div>
        <div style={{ fontSize: 20, fontWeight: 500, color: "var(--text-primary)", letterSpacing: -0.2, marginBottom: 10 }}>
          Şifrenizi mi unuttunuz?
        </div>
        <div style={{ fontSize: 13, color: "var(--text-secondary)", lineHeight: 1.55, marginBottom: 28 }}>
          Kurumsal e-posta adresinize bir sıfırlama bağlantısı göndereceğiz. Bağlantı 30 dakika geçerli olacaktır.
        </div>

        <form onSubmit={submit}>
          <label className="label" style={{ display: "block", marginBottom: 8 }}>KURUMSAL E-POSTA</label>
          <div style={{ position: "relative" }}>
            <div style={{ position: "absolute", left: 14, top: "50%", transform: "translateY(-50%)", color: "var(--text-tertiary)" }}>
              <Icon name="mail" size={18} />
            </div>
            <input
              className="input"
              value={email}
              onChange={e => { setEmail(e.target.value); setErr(null); }}
              onFocus={() => setFocus(true)}
              onBlur={() => setFocus(false)}
              style={{
                paddingLeft: 42,
                borderColor: err ? "var(--error)" : (focus ? "var(--navy)" : "var(--surface-input-border)"),
              }}
              placeholder="ad.soyad@guvenok.com.tr"
              autoFocus
            />
          </div>
          {err && <div style={{ fontSize: 11, color: "var(--error)", marginTop: 6 }}>{err}</div>}

          <button type="submit" disabled={loading} style={{
            marginTop: 22,
            width: "100%", height: 48,
            background: loading ? "var(--navy-dark)" : "var(--navy)",
            color: "#fff", border: "none", borderRadius: 8,
            fontFamily: "var(--font)", fontSize: 14, fontWeight: 500,
            cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", gap: 8,
          }}>
            {loading ? "Gönderiliyor…" : <>Sıfırlama Linki Gönder<Icon name="arrowRight" size={14} color="#fff" /></>}
          </button>

          <button type="button" onClick={onBack} style={{
            marginTop: 12, width: "100%", height: 44,
            background: "transparent", color: "var(--navy)", border: "none", cursor: "pointer",
            fontFamily: "var(--font)", fontSize: 13, fontWeight: 500,
          }}>
            ← Giriş ekranına dön
          </button>
        </form>
      </div>
    </div>
  );
}

// ─── 02b Email Gönderildi (Confirmation) ───
function PasswordEmailSentScreen({ email = "ad.soyad@guvenok.com.tr", onBackToLogin, onOpenReset }) {
  const [cooldown, setCooldown] = React.useState(60);
  React.useEffect(() => {
    if (cooldown <= 0) return;
    const t = setTimeout(() => setCooldown(c => c - 1), 1000);
    return () => clearTimeout(t);
  }, [cooldown]);

  return (
    <div style={{ height: "100%", background: "var(--surface-white)", display: "flex", flexDirection: "column" }}>
      <PageHeader title="E-posta Gönderildi" back={onBackToLogin} subtitle="ASSETFLOW" />
      <div style={{ flex: 1, overflow: "auto", padding: "40px 28px", display: "flex", flexDirection: "column", alignItems: "center", textAlign: "center" }}>
        <div style={{
          width: 72, height: 72, borderRadius: "50%", background: "var(--success-bg)",
          display: "flex", alignItems: "center", justifyContent: "center", marginBottom: 22,
          border: "1px solid var(--success)",
        }}>
          <Icon name="check" size={32} color="var(--success)" strokeWidth={2.2} />
        </div>
        <div style={{ fontSize: 20, fontWeight: 500, color: "var(--text-primary)", marginBottom: 10 }}>
          E-posta gönderildi
        </div>
        <div style={{ fontSize: 13, color: "var(--text-secondary)", lineHeight: 1.55, maxWidth: 300, marginBottom: 6 }}>
          Sıfırlama bağlantısı aşağıdaki adrese gönderildi. Gelen kutunuzu ve spam klasörünüzü kontrol edin.
        </div>
        <div style={{
          marginTop: 14, padding: "10px 14px",
          background: "var(--surface-light)", borderRadius: 8,
          fontFamily: "ui-monospace, SFMono-Regular, Menlo, monospace",
          fontSize: 12, color: "var(--navy)",
        }}>{email}</div>

        <div style={{ marginTop: 32, width: "100%" }}>
          <button onClick={onOpenReset} style={{
            width: "100%", height: 48,
            background: "var(--navy)", color: "#fff", border: "none", borderRadius: 8,
            fontFamily: "var(--font)", fontSize: 14, fontWeight: 500, cursor: "pointer",
            display: "flex", alignItems: "center", justifyContent: "center", gap: 8,
          }}>
            E-postamı Aç (Demo)
            <Icon name="arrowRight" size={14} color="#fff" />
          </button>
          <button
            disabled={cooldown > 0}
            onClick={() => setCooldown(60)}
            style={{
              marginTop: 10, width: "100%", height: 44,
              background: "var(--surface-white)",
              color: cooldown > 0 ? "var(--text-tertiary)" : "var(--navy)",
              border: "1px solid var(--surface-input-border)", borderRadius: 8,
              fontFamily: "var(--font)", fontSize: 13, fontWeight: 500,
              cursor: cooldown > 0 ? "not-allowed" : "pointer",
            }}>
            {cooldown > 0 ? `Yeniden gönder (${cooldown}s)` : "Yeniden gönder"}
          </button>
          <button onClick={onBackToLogin} style={{
            marginTop: 14, width: "100%", background: "transparent",
            border: "none", cursor: "pointer",
            fontFamily: "var(--font)", fontSize: 12, color: "var(--text-secondary)",
          }}>← Giriş ekranına dön</button>
        </div>
      </div>
    </div>
  );
}

// ─── 02c Yeni Şifre Belirle ───
function strengthOf(pw) {
  let s = 0;
  if (pw.length >= 8) s++;
  if (/[A-Z]/.test(pw)) s++;
  if (/[0-9]/.test(pw)) s++;
  if (/[^A-Za-z0-9]/.test(pw)) s++;
  return s; // 0..4
}
function ResetPasswordScreen({ onBackToLogin, onDone }) {
  const [p1, setP1] = React.useState("");
  const [p2, setP2] = React.useState("");
  const [show, setShow] = React.useState(false);
  const [err, setErr] = React.useState(null);
  const [ok, setOk] = React.useState(false);

  const s = strengthOf(p1);
  const strengthLabel = s <= 1 ? "Zayıf" : s === 2 ? "Orta" : s >= 3 ? "Güçlü" : "—";
  const strengthColor = s <= 1 ? "var(--error)" : s === 2 ? "var(--warning)" : "var(--success)";

  const submit = (e) => {
    e.preventDefault();
    if (p1.length < 8) return setErr("Şifre en az 8 karakter olmalı.");
    if (p1 !== p2)     return setErr("Şifreler eşleşmiyor.");
    if (s < 2)          return setErr("Daha güçlü bir şifre seçin (harf, sayı, özel karakter).");
    setErr(null); setOk(true);
    setTimeout(() => onDone && onDone(), 900);
  };

  return (
    <div style={{ height: "100%", background: "var(--surface-white)", display: "flex", flexDirection: "column" }}>
      <PageHeader title="Yeni Şifre" back={onBackToLogin} subtitle="ASSETFLOW" />
      <div style={{ flex: 1, overflow: "auto", padding: "28px 28px 40px" }}>
        {ok ? (
          <div style={{ textAlign: "center", padding: "40px 0" }}>
            <div style={{
              width: 72, height: 72, borderRadius: "50%", background: "var(--success-bg)",
              display: "flex", alignItems: "center", justifyContent: "center",
              margin: "0 auto 20px", border: "1px solid var(--success)",
            }}>
              <Icon name="check" size={32} color="var(--success)" strokeWidth={2.2} />
            </div>
            <div style={{ fontSize: 20, fontWeight: 500, color: "var(--text-primary)", marginBottom: 8 }}>Şifre güncellendi</div>
            <div style={{ fontSize: 13, color: "var(--text-secondary)" }}>Yeni şifrenizle giriş yapabilirsiniz.</div>
          </div>
        ) : (
          <>
            <div style={{ fontSize: 20, fontWeight: 500, color: "var(--text-primary)", marginBottom: 10 }}>
              Yeni şifre belirle
            </div>
            <div style={{ fontSize: 13, color: "var(--text-secondary)", lineHeight: 1.55, marginBottom: 24 }}>
              En az 8 karakter, büyük harf, sayı ve özel karakter içermesi önerilir.
            </div>

            <form onSubmit={submit}>
              <label className="label" style={{ display: "block", marginBottom: 8 }}>YENİ ŞİFRE</label>
              <div style={{ position: "relative", marginBottom: 14 }}>
                <div style={{ position: "absolute", left: 14, top: "50%", transform: "translateY(-50%)", color: "var(--text-tertiary)" }}>
                  <Icon name="lock" size={18} />
                </div>
                <input className="input" type={show ? "text" : "password"} value={p1}
                  onChange={e => { setP1(e.target.value); setErr(null); }}
                  style={{ paddingLeft: 42, paddingRight: 42 }} placeholder="••••••••" />
                <button type="button" onClick={() => setShow(v => !v)} style={{
                  position: "absolute", right: 8, top: "50%", transform: "translateY(-50%)",
                  width: 32, height: 32, border: "none", background: "transparent", cursor: "pointer",
                  color: "var(--text-tertiary)", display: "flex", alignItems: "center", justifyContent: "center",
                }}>
                  <Icon name={show ? "eyeOff" : "eye"} size={18} />
                </button>
              </div>

              {/* Strength meter */}
              {p1 && (
                <div style={{ marginBottom: 18 }}>
                  <div style={{ display: "flex", gap: 4, height: 4, marginBottom: 6 }}>
                    {[1,2,3,4].map(i => (
                      <div key={i} style={{
                        flex: 1, borderRadius: 2,
                        background: i <= s ? strengthColor : "var(--surface-light)",
                      }} />
                    ))}
                  </div>
                  <div style={{ fontSize: 11, color: strengthColor, fontWeight: 500 }}>{strengthLabel}</div>
                </div>
              )}

              <label className="label" style={{ display: "block", marginBottom: 8 }}>ŞİFRE TEKRAR</label>
              <div style={{ position: "relative" }}>
                <div style={{ position: "absolute", left: 14, top: "50%", transform: "translateY(-50%)", color: "var(--text-tertiary)" }}>
                  <Icon name="lock" size={18} />
                </div>
                <input className="input" type={show ? "text" : "password"} value={p2}
                  onChange={e => { setP2(e.target.value); setErr(null); }}
                  style={{ paddingLeft: 42 }} placeholder="••••••••" />
              </div>

              {err && <div style={{ fontSize: 11, color: "var(--error)", marginTop: 10 }}>{err}</div>}
              {p2 && p1 === p2 && !err && (
                <div style={{ fontSize: 11, color: "var(--success)", marginTop: 10, display: "flex", alignItems: "center", gap: 6 }}>
                  <Icon name="check" size={12} color="var(--success)" /> Şifreler eşleşiyor
                </div>
              )}

              <button type="submit" style={{
                marginTop: 24, width: "100%", height: 48,
                background: "var(--navy)", color: "#fff", border: "none", borderRadius: 8,
                fontFamily: "var(--font)", fontSize: 14, fontWeight: 500, cursor: "pointer",
              }}>
                Şifreyi Güncelle
              </button>
            </form>
          </>
        )}
      </div>
    </div>
  );
}

Object.assign(window, { ForgotPasswordScreen, PasswordEmailSentScreen, ResetPasswordScreen });
