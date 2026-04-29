import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        title: Text(
          'Gizlilik Politikası',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _PolicySection(
            title: '1. Genel Bilgiler',
            content:
                'AssetFlow, kurumsal IT varlık yönetimi için tasarlanmış bir uygulamadır. Bu Gizlilik Politikası, AssetFlow mobil uygulaması aracılığıyla toplanan, işlenen ve saklanan verilere ilişkin uygulamalarımızı açıklamaktadır.\n\nUygulamayı kullanarak bu politikayı kabul etmiş sayılırsınız.',
          ),
          _PolicySection(
            title: '2. Toplanan Veriler',
            content:
                'AssetFlow yalnızca uygulama işlevselliği için gerekli verileri toplar:\n\n• Hesap bilgileri: Ad, soyad, e-posta adresi, şifre (şifrelenmiş)\n• Profil fotoğrafı: İsteğe bağlı, yalnızca yüklemeniz durumunda\n• Cihaz ve varlık verileri: Şirketinizin IT varlıklarına ilişkin bilgiler\n• Kullanım verileri: Uygulama içi işlemler (zimmet, atama, iade kayıtları)\n• Uygulama günlükleri: Hata ayıklama ve güvenlik amacıyla tutulan teknik kayıtlar',
          ),
          _PolicySection(
            title: '3. Verilerin Kullanımı',
            content:
                'Toplanan veriler aşağıdaki amaçlarla kullanılmaktadır:\n\n• IT varlık yönetimi hizmetlerinin sağlanması\n• Kullanıcı kimlik doğrulaması ve yetkilendirme\n• Zimmet ve atama takibi\n• Bildirim gönderimi\n• Uygulama güvenliği ve hata ayıklama\n\nKişisel verileriniz üçüncü taraflarla paylaşılmaz veya reklam amacıyla kullanılmaz.',
          ),
          _PolicySection(
            title: '4. Veri Güvenliği',
            content:
                'Verilerinizin güvenliğini sağlamak için aşağıdaki önlemler alınmaktadır:\n\n• Tüm veri iletimi HTTPS (TLS) ile şifrelenmektedir\n• Şifreler şifrelenmiş olarak saklanmakta, düz metin olarak tutulmamaktadır\n• Sunucu erişimi kısıtlıdır ve düzenli olarak izlenmektedir\n• Her şirketin verileri birbirinden izole edilmiş şekilde tutulmaktadır (multi-tenancy)',
          ),
          _PolicySection(
            title: '5. İzinler',
            content:
                'AssetFlow mobil uygulaması aşağıdaki izinleri kullanmaktadır:\n\n• Kamera: Cihaz barkodlarını taramak için kullanılır\n• Fotoğraf Kitaplığı: Profil fotoğrafı yüklemek için kullanılır\n• Bildirimler: Zimmet ve sistem bildirimleri için kullanılır\n\nBu izinler yalnızca ilgili özellik kullanıldığında aktif olur ve hiçbir veri şirket sunucuları dışında paylaşılmaz.',
          ),
          _PolicySection(
            title: '6. Veri Saklama ve Silme',
            content:
                'Verileriniz hesabınız aktif olduğu sürece saklanır. Hesabınızı silmek istediğinizde:\n\n• Mobil uygulama üzerinden: Profil → Hesabımı Sil seçeneğini kullanabilirsiniz\n• Hesap silindiğinde kişisel verileriniz (ad, e-posta, profil fotoğrafı) kalıcı olarak silinir\n• Şirkete ait varlık kayıtları, kurumsal denetim amacıyla şirket yöneticisi tarafından yönetilir',
          ),
          _PolicySection(
            title: '7. Üçüncü Taraf Hizmetler',
            content:
                'AssetFlow şu an herhangi bir analitik veya reklam SDK\'sı kullanmamaktadır. Uygulama verileri yalnızca şirketinizin yapılandırmasına göre belirlenen sunucularda saklanır.',
          ),
          _PolicySection(
            title: '8. İletişim',
            content:
                'Gizlilik politikasına ilişkin sorularınız için:\n\nE-posta: info@mobnet.online\nWeb: mobnet.online',
            isLast: true,
          ),
          Padding(
            padding: EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              'Son güncelleme: 28 Nisan 2026',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final String content;
  final bool isLast;

  const _PolicySection({
    required this.title,
    required this.content,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.surfaceDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
