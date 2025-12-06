// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'MediGo';

  @override
  String get getStarted => 'Commencer';

  @override
  String get findNearbyPharmacies => 'Trouver les pharmacies à proximité';

  @override
  String get discoverPharmaciesDescription =>
      'Découvrez les pharmacies près de chez vous avec un suivi de distance en temps réel et une navigation facile.';

  @override
  String get next => 'Suivant';

  @override
  String get skip => 'Passer';

  @override
  String get searchMedicines => 'Rechercher des médicaments';

  @override
  String get searchMedicinesDescription =>
      'Trouvez rapidement les médicaments dont vous avez besoin grâce à notre fonction de recherche intelligente.';

  @override
  String get medicineReminders => 'Rappels de médicaments';

  @override
  String get medicineRemindersDescription =>
      'Ne manquez jamais votre traitement grâce aux rappels personnalisés et au suivi de vos soins.';

  @override
  String get contactDirections => 'Contact et itinéraire';

  @override
  String get contactDirectionsDescription =>
      'Obtenez des informations détaillées sur les pharmacies, l’itinéraire et contactez-les directement depuis l’application.';

  @override
  String get noAccountFound => 'Aucun compte trouvé pour cet e-mail';

  @override
  String get welcomeTo => 'Bienvenue à ';

  @override
  String get logIn => 'Se connecter';

  @override
  String get email => 'E-mail';

  @override
  String get pleaseEnterEmail => 'Please enter your email';

  @override
  String get password => 'Mot de passe';

  @override
  String get enterPassword => 'Veuillez entrer votre mot de passe';

  @override
  String get forgetPassword => 'Mot de passe oublié ?';

  @override
  String get orLoginWith => 'Ou se connecter avec';

  @override
  String get noAccount => 'Vous n’avez pas de compte ? ';

  @override
  String get signUp => 'S’inscrire';

  @override
  String get fullName => 'Nom complet';

  @override
  String get enterFullName => 'Entrez votre nom complet';

  @override
  String get pleaseEnterName => 'Veuillez entrer votre nom';

  @override
  String get enterEmail => 'Veuillez entrer votre e-mail';

  @override
  String get validEmail => 'Veuillez entrer un e-mail valide';

  @override
  String get phoneNumber => 'Numéro de téléphone';

  @override
  String get enterPhoneNumber => 'Veuillez entrer votre numéro de téléphone';

  @override
  String get orSignUpWith => 'Ou s’inscrire avec';

  @override
  String get alreadyHaveAccount => 'Vous avez déjà un compte ? ';

  @override
  String get selectGenderPrompt => 'Veuillez sélectionner votre genre';

  @override
  String get selectDOBPrompt => 'Veuillez sélectionner votre date de naissance';

  @override
  String get gender => 'Genre';

  @override
  String get select => 'Sélectionner';

  @override
  String get male => 'Homme';

  @override
  String get female => 'Femme';

  @override
  String get other => 'Autre';

  @override
  String get dateOfBirth => 'Date de naissance';

  @override
  String get dobFormat => 'jj/mm/aaaa';

  @override
  String get createPassword => 'Créez votre mot de passe';

  @override
  String get passwordMinLength =>
      'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get confirmYourPassword => 'Confirmez votre mot de passe';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get hi => 'Salut ';

  @override
  String get howAreYouFeeling => ' ,Comment vous\nsentez-vous aujourd’hui ?';

  @override
  String get searchMedicinePrompt => 'Recherchez votre médicament ...';

  @override
  String get medicineReminder => 'Rappel de médicament';

  @override
  String get reminderDescription =>
      'Vous voulez un rappel pour suivre votre traitement';

  @override
  String get startNow => 'Commencer maintenant';

  @override
  String get nearbyPharmacy => 'Pharmacie à proximité';

  @override
  String rating(Object rating) {
    return 'Évaluation: \$rating';
  }

  @override
  String reviews(Object reviews) {
    return '(\$reviews)';
  }

  @override
  String get findYourMedicine => 'Trouvez votre médicament';

  @override
  String get searchYourMedicine => 'Recherchez votre médicament';

  @override
  String get noResultsFound => 'Aucun résultat trouvé';

  @override
  String get inStock => 'En stock';

  @override
  String get outOfStock => 'En rupture de stock';

  @override
  String get preOrder => 'Pré-commande';

  @override
  String get pharmacyIdMissing => 'Identifiant de pharmacie manquant';

  @override
  String get profileScreen => 'Écran du profil';

  @override
  String get calendarScreen => 'Écran du calendrier';

  @override
  String get logoutConfirmation =>
      'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get cancel => 'Annuler';

  @override
  String get logOut => 'Se déconnecter';

  @override
  String get notSpecified => 'Non spécifié';

  @override
  String get profile => 'Profil';

  @override
  String get premiumPlan => 'Forfait Premium';

  @override
  String get freePlan => 'Forfait Gratuit';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get upgradeToPremium => 'Passer à Premium';

  @override
  String get premiumDescription =>
      'Profitez d’une expérience sans publicité, de réservations prioritaires et d’alertes de réapprovisionnement instantanées';

  @override
  String get upgradeNowPrice => 'Passer maintenant - 3000DA/an';

  @override
  String get settings => 'Paramètres';

  @override
  String get myReservations => 'Mes réservations';

  @override
  String activeReservations(Object activeReservationsCount) {
    return '\$activeReservationsCount réservations actives';
  }

  @override
  String get notifications => 'Notifications';

  @override
  String get receiveMedicineReminders => 'Recevoir des rappels de médicaments';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get darkModeDescription => 'Passer au thème sombre';

  @override
  String get language => 'Langue';

  @override
  String get privacySecurityPage => 'Page Confidentialité & Sécurité';

  @override
  String get privacySecurity => 'Confidentialité et Sécurité';

  @override
  String get privacySecurityDescription =>
      'Gérez vos données - Page Confidentialité et Sécurité';

  @override
  String get aboutMedigo => 'À propos de MediGo';

  @override
  String get aboutMedigoPage => 'Page À propos de MediGo';

  @override
  String get profileUpdated => 'Profil mis à jour avec succès';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get enterNewPassword => 'Entrez votre nouveau mot de passe';

  @override
  String get confirmNewPassword => 'Confirmez le nouveau mot de passe';

  @override
  String get enterConfirmNewPassword =>
      'Entrez la confirmation de votre nouveau mot de passe';

  @override
  String get pleaseConfirmPassword => 'Veuillez confirmer votre mot de passe';

  @override
  String get subscription => 'Abonnement';

  @override
  String get chooseYourPlan => 'Choisissez votre formule';

  @override
  String get subscriptionAgreement =>
      'En vous abonnant, vous acceptez nos Conditions d\'utilisation et notre Politique de confidentialité. L’abonnement se renouvelle automatiquement sauf annulation.';

  @override
  String get subscribeMonthly => 'S’abonner mensuellement';

  @override
  String get billedAnnually => 'Facturé annuellement';

  @override
  String get yearly => 'Annuel';

  @override
  String get monthly => 'Mensuel';

  @override
  String get billedMonthly => 'Facturé mensuellement';

  @override
  String get perMonth => '/mois';

  @override
  String get perYear => 'par an';

  @override
  String get subscribeYearly => 'S’abonner annuellement (Meilleure offre)';

  @override
  String get success => 'Succès !';

  @override
  String get ok => 'OK';

  @override
  String subscriptionSuccessMessage(Object planName) {
    return 'Vous vous êtes abonné avec succès à la formule \$planName !';
  }

  @override
  String get medicinePreOrderReservation =>
      'Précommande et réservation de médicaments';

  @override
  String get medicinePreOrderDescription =>
      'Précommandez vos médicaments, réservez-les puis passez les récupérer quand vous êtes libre';

  @override
  String get instantRestockAlerts =>
      'Alertes de réapprovisionnement instantanées';

  @override
  String get instantRestockDescription =>
      'Recevez une notification dès que les médicaments en rupture de stock sont disponibles';

  @override
  String get adFreeExperience => 'Expérience sans publicité';

  @override
  String get adFreeDescription =>
      'Profitez d’une interface propre et sans distractions, sans aucune publicité';

  @override
  String get yourCurrentMedicines => 'Vos médicaments actuels';

  @override
  String get tracking => 'Suivi';

  @override
  String get edit => 'Modifier';

  @override
  String get statistics => 'Statistiques';

  @override
  String get haveYouTakentYourMedicineToday =>
      'Avez-vous pris votre médicament aujourd\'hui ?';

  @override
  String get morning => 'Matin';

  @override
  String get evening => 'Soir';

  @override
  String get addMedicine => 'Ajouter un médicament';

  @override
  String get medicineName => 'Nom du médicament';

  @override
  String get enterMedicineName => 'Entrez le nom du médicament';

  @override
  String get medicineType => 'Type de médicament';

  @override
  String get dose => 'Dose';

  @override
  String get enterDoseExample => 'ex : 500';

  @override
  String get unit => 'Unité';

  @override
  String get frequency => 'Fréquence';

  @override
  String get timesPerDay => 'Combien de fois par jour';

  @override
  String get time => 'Heure';

  @override
  String get selectTime => 'Sélectionner l’heure';

  @override
  String get startDate => 'Date de début';

  @override
  String get endDate => 'Date de fin';

  @override
  String get selectDate => 'Sélectionner la date';

  @override
  String get importance => 'Importance';

  @override
  String get notes => 'Notes';

  @override
  String get enterNotes => 'Écrire une note (optionnel)';

  @override
  String get save => 'Enregistrer';

  @override
  String get perDay => 'Par jour';

  @override
  String get perWeek => 'Par semaine';

  @override
  String get eachNDays => 'Chaque N jours';

  @override
  String get customized => 'Personnalisé';

  @override
  String get yourProgress => 'Votre progression';

  @override
  String get medProgress => 'Progression du médicament';

  @override
  String get add => 'Add';

  @override
  String get no_medicines_for_day => 'Aucun médicament pour ce jour';

  @override
  String get cannot_update_item => 'Impossible de mettre à jour cet élément';

  @override
  String get marked_as_done => 'Marqué comme pris';

  @override
  String get unmarked => 'Démarqué';

  @override
  String get failed_to_mark => 'Échec du marquage';

  @override
  String get failed_to_unmark => 'Échec du démarquage';

  @override
  String get cannot_edit_item => 'Impossible de modifier cet élément';

  @override
  String get could_not_find_plan_for_occurrence =>
      'Impossible de trouver le plan pour cette occurrence';

  @override
  String get delete => 'Supprimer';

  @override
  String get delete_occurrence_title => 'Supprimer l’occurrence';

  @override
  String get delete_occurrence_text =>
      'Êtes-vous sûr de vouloir supprimer cette occurrence ?';

  @override
  String how_many_times_on_day(Object day) {
    return 'Combien de fois le $day';
  }

  @override
  String get select_start_date => 'Sélectionnez la date de début';

  @override
  String get select_end_date => 'Sélectionnez la date de fin';

  @override
  String get start_end_dates_required =>
      'Les dates de début et de fin sont obligatoires';

  @override
  String get start_date_before_or_equal_end_date =>
      'La date de début doit être avant ou égale à la date de fin';

  @override
  String get medicine_added => 'Médicament ajouté';

  @override
  String get failed_to_add_medicine => 'Échec de l’ajout du médicament';

  @override
  String get nothing_to_save => 'Rien à enregistrer';

  @override
  String get saved => 'Enregistré';

  @override
  String get name_is_required => 'Le nom est obligatoire';

  @override
  String get dose_must_be_greater_than_zero =>
      'La dose doit être supérieure à 0';

  @override
  String get times_per_day_required =>
      'Le nombre de prises par jour est requis';

  @override
  String get start_date_must_before_end_date =>
      'La date de début doit être avant la date de fin';

  @override
  String get today_taken => 'Pris aujourd’hui';

  @override
  String get medicines_progress => 'Progression des médicaments';

  @override
  String get unnamed => 'Sans nom';

  @override
  String get removed => 'Supprimé';

  @override
  String get failed_to_remove => 'Échec de la suppression';
}
