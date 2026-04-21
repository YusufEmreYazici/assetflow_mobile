// Login / Splash — AssetFlow
// Centered wordmark, GÜVENOK company tag, email + password, primary CTA.

function LoginScreen({ onLogin }) {
  const [email, setEmail] = React.useState("zeynep.aksoy@guvenok.com.tr");
  const [pass, setPass]   = React.useState("••••••••••");
  const [showPass, setShow] = React.useState(false);
  const [focus, setFocus] = React.useState(null);
  const [loading, setLoading] = React.useState(false);

  const submit = (e) => {
    e && e.preventDefault();
    setLoading(true);
    setTimeout(() => { setLoading(false); onLogin && onLogin(); }, 850);
  };

  return (
    <div style={{
      height: "100%", width: "100%",
      background: "var(--surface-white)",
      display: "flex", flexDirection: "column",
      padding: "0 28px",
    }}>
      {/* Thin top status-bar safe area is handled by iOS frame.
          We start with a tall header block featuring the wordmark. */}

      <div style={{ flex: 1, display: "flex", flexDirection: "column", justifyContent: "center", paddingTop: 60 }}>
        {/* Brand block */}
        <div style={{ marginBottom: 48 }}>
          {/* Wordmark — navy, sized like a heading */}
          <div style={{ display: "flex", alignItems: "baseline", gap: 2, marginBottom: 8 }}>
            <div style={{
              fontFamily: "var(--font)",
              fontSize: 34, fontWeight: 500, letterSpacing: -1,
              color: "var(--navy)",
            }}>Asset</div>
            <div style={{
              fontFamily: "var(--font)",
              fontSize: 34, fontWeight: 300, letterSpacing: -1,
              color: "var(--navy)",
            }}>Flow</div>
            <div style={{
              width: 6, height: 6, borderRadius: 2,
              background: "var(--navy)", marginLeft: 4, transform: "translateY(-4px)",
            }} />
          </div>
          {/* Tagline */}
          <div style={{
            fontSize: 11, fontWeight: 500, letterSpacing: 1.4,
            color: "var(--text-secondary)", textTransform: "uppercase",
          }}>IT Varlık Yönetim Sistemi</div>

          {/* Divider */}
          <div style={{
            width: 32, height: 2, background: "var(--navy)", marginTop: 24,
          }} />

          <div style={{
            fontSize: 14, color: "var(--text-secondary)", lineHeight: 1.5,
            marginTop: 16, maxWidth: 280,
          }}>
            Kurumsal hesabınızla giriş yaparak şirket varlıklarınızı yönetin.
          </div>
        </div>

        {/* Form */}
        <form onSubmit={submit}>
          <div style={{ marginBottom: 18 }}>
            <label className="label" style={{ display: "block", marginBottom: 8 }}>KURUMSAL E-POSTA</label>
            <div style={{ position: "relative" }}>
              <div style={{ position: "absolute", left: 14, top: "50%", transform: "translateY(-50%)", color: "var(--text-tertiary)" }}>
                <Icon name="mail" size={18} />
              </div>
              <input
                className="input"
                value={email}
                onChange={e => setEmail(e.target.value)}
                onFocus={() => setFocus("email")}
                onBlur={() => setFocus(null)}
                style={{
                  paddingLeft: 42,
                  borderColor: focus === "email" ? "var(--navy)" : "var(--surface-input-border)",
                }}
                placeholder="ad.soyad@guvenok.com.tr"
              />
            </div>
          </div>

          <div style={{ marginBottom: 14 }}>
            <label className="label" style={{ display: "block", marginBottom: 8 }}>ŞİFRE</label>
            <div style={{ position: "relative" }}>
              <div style={{ position: "absolute", left: 14, top: "50%", transform: "translateY(-50%)", color: "var(--text-tertiary)" }}>
                <Icon name="lock" size={18} />
              </div>
              <input
                className="input"
                type={showPass ? "text" : "password"}
                value={pass}
                onChange={e => setPass(e.target.value)}
                onFocus={() => setFocus("pass")}
                onBlur={() => setFocus(null)}
                style={{
                  paddingLeft: 42, paddingRight: 42,
                  borderColor: focus === "pass" ? "var(--navy)" : "var(--surface-input-border)",
                }}
                placeholder="••••••••"
              />
              <button type="button" onClick={() => setShow(s => !s)} style={{
                position: "absolute", right: 8, top: "50%", transform: "translateY(-50%)",
                width: 32, height: 32, border: "none", background: "transparent", cursor: "pointer",
                color: "var(--text-tertiary)", display: "flex", alignItems: "center", justifyContent: "center",
              }}>
                <Icon name={showPass ? "eyeOff" : "eye"} size={18} />
              </button>
            </div>
          </div>

          <div style={{ display: "flex", justifyContent: "flex-end", marginBottom: 28 }}>
            <button type="button" className="btn-ghost" style={{
              background: "transparent", border: "none", cursor: "pointer", padding: 0,
              fontSize: 12, color: "var(--navy-light)", fontWeight: 500,
            }}>
              Şifremi unuttum
            </button>
          </div>

          <button type="submit" disabled={loading} style={{
            width: "100%", height: 48,
            background: loading ? "var(--navy-dark)" : "var(--navy)",
            color: "#fff", border: "none", borderRadius: 8,
            fontFamily: "var(--font)", fontSize: 14, fontWeight: 500, letterSpacing: 0.2,
            cursor: "pointer",
            display: "flex", alignItems: "center", justifyContent: "center", gap: 8,
          }}>
            {loading ? (
              <>
                <svg width="16" height="16" viewBox="0 0 24 24">
                  <circle cx="12" cy="12" r="9" fill="none" stroke="rgba(255,255,255,0.3)" strokeWidth="2.5" />
                  <path d="M21 12a9 9 0 0 1-9 9" fill="none" stroke="#fff" strokeWidth="2.5" strokeLinecap="round">
                    <animateTransform attributeName="transform" type="rotate" from="0 12 12" to="360 12 12" dur="0.8s" repeatCount="indefinite" />
                  </path>
                </svg>
                Giriş yapılıyor…
              </>
            ) : (
              <>
                Giriş Yap
                <Icon name="arrowRight" size={16} color="#fff" />
              </>
            )}
          </button>

          {/* Secondary option */}
          <div style={{
            marginTop: 14,
            display: "flex", alignItems: "center", justifyContent: "center", gap: 8,
            fontSize: 12, color: "var(--text-secondary)",
          }}>
            <div style={{ width: 24, height: 1, background: "var(--surface-divider)" }} />
            <span>veya</span>
            <div style={{ width: 24, height: 1, background: "var(--surface-divider)" }} />
          </div>

          <button type="button" style={{
            width: "100%", height: 44, marginTop: 14,
            background: "var(--surface-white)", color: "var(--navy)",
            border: "1px solid var(--surface-input-border)", borderRadius: 8,
            fontFamily: "var(--font)", fontSize: 13, fontWeight: 500,
            cursor: "pointer",
            display: "flex", alignItems: "center", justifyContent: "center", gap: 8,
          }}>
            <Icon name="lock" size={14} color="var(--navy)" />
            SSO ile giriş (Active Directory)
          </button>
        </form>
      </div>

      {/* Footer */}
      <div style={{
        paddingBottom: 40, paddingTop: 24,
        display: "flex", justifyContent: "space-between", alignItems: "center",
        fontSize: 10, color: "var(--text-tertiary)", letterSpacing: 0.4,
      }}>
        <span>v2.4.1 · build 2614</span>
        <span>© 2026 AssetFlow</span>
      </div>
    </div>
  );
}

Object.assign(window, { LoginScreen });
