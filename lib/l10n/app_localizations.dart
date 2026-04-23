import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// Uygulama adı
  ///
  /// In tr, this message translates to:
  /// **'AssetFlow'**
  String get appTitle;

  /// Kaydet butonu
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get save;

  /// İptal butonu
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get cancel;

  /// Sil butonu
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get delete;

  /// Düzenle butonu
  ///
  /// In tr, this message translates to:
  /// **'Düzenle'**
  String get edit;

  /// Onay butonu
  ///
  /// In tr, this message translates to:
  /// **'Onayla'**
  String get confirm;

  /// Kapat butonu
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get close;

  /// Yükleniyor mesajı
  ///
  /// In tr, this message translates to:
  /// **'Yükleniyor...'**
  String get loading;

  /// Hata başlığı
  ///
  /// In tr, this message translates to:
  /// **'Hata'**
  String get error;

  /// Tekrar dene butonu
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Dene'**
  String get retry;

  /// Arama
  ///
  /// In tr, this message translates to:
  /// **'Ara'**
  String get search;

  /// Sonuç yok mesajı
  ///
  /// In tr, this message translates to:
  /// **'Sonuç bulunamadı'**
  String get noResults;

  /// Giriş ekranı başlığı
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get loginTitle;

  /// E-posta alanı
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get emailLabel;

  /// Şifre alanı
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get passwordLabel;

  /// E-posta validasyon hatası
  ///
  /// In tr, this message translates to:
  /// **'E-posta gerekli'**
  String get emailRequired;

  /// Geçersiz e-posta hatası
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir e-posta girin'**
  String get emailInvalid;

  /// Şifre validasyon hatası
  ///
  /// In tr, this message translates to:
  /// **'Şifre gerekli'**
  String get passwordRequired;

  /// Çıkış yap
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap'**
  String get logout;

  /// Çıkış onay mesajı
  ///
  /// In tr, this message translates to:
  /// **'Oturumunuzu kapatmak istiyor musunuz?'**
  String get logoutConfirm;

  /// Dashboard nav etiketi
  ///
  /// In tr, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// Cihazlar nav etiketi
  ///
  /// In tr, this message translates to:
  /// **'Cihazlar'**
  String get navDevices;

  /// Personel nav etiketi
  ///
  /// In tr, this message translates to:
  /// **'Personel'**
  String get navEmployees;

  /// Zimmetler nav etiketi
  ///
  /// In tr, this message translates to:
  /// **'Zimmetler'**
  String get navAssignments;

  /// Daha fazla nav etiketi
  ///
  /// In tr, this message translates to:
  /// **'Daha Fazla'**
  String get navMore;

  /// Cihaz ekle başlığı
  ///
  /// In tr, this message translates to:
  /// **'Cihaz Ekle'**
  String get deviceAdd;

  /// Cihaz düzenle başlığı
  ///
  /// In tr, this message translates to:
  /// **'Cihazı Düzenle'**
  String get deviceEdit;

  /// Cihaz sil başlığı
  ///
  /// In tr, this message translates to:
  /// **'Cihazı Sil'**
  String get deviceDelete;

  /// Cihaz silme onay mesajı
  ///
  /// In tr, this message translates to:
  /// **'Bu cihazı silmek istediğinize emin misiniz?'**
  String get deviceDeleteConfirm;

  /// Cihaz bulunamadı hatası
  ///
  /// In tr, this message translates to:
  /// **'Cihaz bulunamadı'**
  String get deviceNotFound;

  /// Aktif durum
  ///
  /// In tr, this message translates to:
  /// **'Aktif'**
  String get deviceStatusActive;

  /// Depoda durumu
  ///
  /// In tr, this message translates to:
  /// **'Depoda'**
  String get deviceStatusInStorage;

  /// Bakımda durumu
  ///
  /// In tr, this message translates to:
  /// **'Bakımda'**
  String get deviceStatusMaintenance;

  /// Emekli durumu
  ///
  /// In tr, this message translates to:
  /// **'Emekli'**
  String get deviceStatusRetired;

  /// Personel ekle başlığı
  ///
  /// In tr, this message translates to:
  /// **'Personel Ekle'**
  String get employeeAdd;

  /// Personel bulunamadı hatası
  ///
  /// In tr, this message translates to:
  /// **'Personel bulunamadı'**
  String get employeeNotFound;

  /// Zimmet oluştur başlığı
  ///
  /// In tr, this message translates to:
  /// **'Zimmet Oluştur'**
  String get assignmentAdd;

  /// İade et butonu
  ///
  /// In tr, this message translates to:
  /// **'İade Et'**
  String get assignmentReturn;

  /// Zaten iade edilmiş hatası
  ///
  /// In tr, this message translates to:
  /// **'Bu zimmet zaten iade edilmiş'**
  String get assignmentAlreadyReturned;

  /// Lokasyon ekle başlığı
  ///
  /// In tr, this message translates to:
  /// **'Lokasyon Ekle'**
  String get locationAdd;

  /// Lokasyon bulunamadı hatası
  ///
  /// In tr, this message translates to:
  /// **'Lokasyon bulunamadı'**
  String get locationNotFound;

  /// Ayarlar başlığı
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settingsTitle;

  /// Dil ayarı başlığı
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get settingsLanguage;

  /// Türkçe dil seçeneği
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get languageTurkish;

  /// İngilizce dil seçeneği
  ///
  /// In tr, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Önbellek temizlendi mesajı
  ///
  /// In tr, this message translates to:
  /// **'Önbellek temizlendi'**
  String get cacheCleared;

  /// Şifre değiştir başlığı
  ///
  /// In tr, this message translates to:
  /// **'Şifreyi Değiştir'**
  String get changePassword;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
