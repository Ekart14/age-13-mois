import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';

List<Map<String, String>> calculerAgeSurPlanetes(
  DateTime naissance,
  DateTime maintenant,
) {
  final joursVecus = maintenant.difference(naissance).inDays.toDouble();
  const planetes = [
    {'nom': 'Mercure', 'periode': 87.97},
    {'nom': 'Vénus', 'periode': 224.70},
    {'nom': 'Terre', 'periode': 365.25},
    {'nom': 'Mars', 'periode': 686.98},
    {'nom': 'Jupiter', 'periode': 4332.59},
    {'nom': 'Saturne', 'periode': 10759.22},
    {'nom': 'Uranus', 'periode': 30688.5},
    {'nom': 'Neptune', 'periode': 60182.0},
  ];

  return planetes.map((planete) {
    final periode = (planete['periode'] as num).toDouble();
    final age = joursVecus / periode;
    return {
      'nom': planete['nom'] as String,
      'age': '~${age.round()}',
    };
  }).toList();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Âge 13 Mois',
      debugShowCheckedModeBanner: false,
      locale: const Locale('fr', 'FR'),
      supportedLocales: const [
        Locale('fr', 'FR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: const Color(0xFFE9E3DF),
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme.apply(bodyColor: Colors.white),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB8C9D8),
          brightness: Brightness.light,
        ),
      ),
      home: AgeCalculatorPage(),
    );
  }
}

class AgeCalculatorPage extends StatefulWidget {
  const AgeCalculatorPage({super.key});

  @override
  _AgeCalculatorPageState createState() => _AgeCalculatorPageState();
}

class _AgeCalculatorPageState extends State<AgeCalculatorPage> {
  DateTime? _dateNaissance;
  String _resultat = '';
  String _comparaison = '';
  String _joursVecus = '';
  String _prochainAnniversaire = '';
  String _textePartage = '';
  List<Map<String, String>> _agesPlanetes = [];

  final _screenshotController = ScreenshotController();
  final GlobalKey _carteKey = GlobalKey();

  String _formatDate(DateTime date) {
    final formatter = DateFormat('EEEE d MMMM y', 'fr_FR');
    return formatter.format(date);
  }

  List<int> _calculerAge13Mois(DateTime naissance, DateTime maintenant) {
    const joursParMois = 28;
    const moisParAn = 13;
    final joursParAn = joursParMois * moisParAn;

    final dateNaissance =
        DateTime(naissance.year, naissance.month, naissance.day);
    final dateMaintenant =
        DateTime(maintenant.year, maintenant.month, maintenant.day);
    final joursVecus = dateMaintenant.difference(dateNaissance).inDays;

    final ans = joursVecus ~/ joursParAn;
    final resteApresAns = joursVecus % joursParAn;
    final mois = resteApresAns ~/ joursParMois;
    final jours = resteApresAns % joursParMois;

    return [ans, mois, jours, joursVecus];
  }

  List<int> _calculerAgeGregorien(DateTime naissance, DateTime maintenant) {
    int ans = maintenant.year - naissance.year;
    int mois = maintenant.month - naissance.month;
    int jours = maintenant.day - naissance.day;

    if (jours < 0) {
      mois--;
      jours += DateTime(maintenant.year, maintenant.month, 0).day;
    }
    if (mois < 0) {
      ans--;
      mois += 12;
    }

    return [ans, mois, jours];
  }

  List<Map<String, String>> _calculerAgeSurPlanetes(
    DateTime naissance,
    DateTime maintenant,
  ) {
    return calculerAgeSurPlanetes(naissance, maintenant);
  }

  String _calculerProchainAnniversaire(DateTime naissance) {
    final now = DateTime.now();
    DateTime dateAnniv = DateTime(now.year, naissance.month, naissance.day);
    if (dateAnniv.isBefore(now)) {
      dateAnniv = DateTime(now.year + 1, naissance.month, naissance.day);
    }
    final joursRestants = dateAnniv.difference(now).inDays;
    return 'Prochain anniversaire (13 mois) : dans $joursRestants jours';
  }

  String _formatJourSemaine(DateTime date) {
    return DateFormat('EEEE', 'fr_FR').format(date);
  }

  String _messageRegularite() {
    if (_dateNaissance == null) {
      return 'Choisissez une date pour voir le jour exact de votre anniversaire dans ce calendrier.';
    }

    final jour = _formatJourSemaine(_dateNaissance!);
    return 'Dans le calendrier de 13 mois, votre anniversaire tombe toujours un $jour, car chaque mois compte 28 jours.';
  }

  Future<void> _pickDate() async {
  final now = DateTime.now();
  final picked = await showDatePicker(
    context: context,
    initialDate: DateTime(1994, 6, 14),
    firstDate: DateTime(1900),
    lastDate: now,
  );
  if (picked != null) {
    try {
      setState(() {
        _dateNaissance = picked;

        final age13 = _calculerAge13Mois(picked, now);
        final ageGreg = _calculerAgeGregorien(picked, now);

        _resultat = '${age13[0]} ans, ${age13[1]} mois, ${age13[2]} jours';
        _comparaison =
            'Âge si 12 mois : ${ageGreg[0]} ans, ${ageGreg[1]} mois, ${ageGreg[2]} jours\n'
            'Âge si 13 mois : ${age13[0]} ans, ${age13[1]} mois, ${age13[2]} jours';
        _joursVecus = 'Total jours vécus : ${age13[3]} jours';
        _prochainAnniversaire = _calculerProchainAnniversaire(picked);
        _agesPlanetes = _calculerAgeSurPlanetes(picked, now);

        _textePartage = '🎉 Mon âge en calendrier de 13 mois :\n'
            'Date de naissance : ${_formatDate(picked)}\n'
            'Résultat : $_resultat\n'
            '$_comparaison\n'
            '$_joursVecus';
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }
}


  Future<void> _copierTexte() async {
    await Clipboard.setData(ClipboardData(text: _textePartage));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Texte copié dans le presse-papier')),
    );
  }

  Future<void> _partagerTexte() async {
    if (_textePartage.isEmpty) return;
    await Share.share(_textePartage);
  }

  Future<void> _partagerImage() async {
    try {
      final imageBytes = await _screenshotController.captureFromWidget(
        _buildResultCard(),
      );
      if (imageBytes == null) return;

      final xfile = XFile.fromData(
        imageBytes,
        name: 'age_13_mois.png',
        mimeType: 'image/png',
      );

      await Share.shareXFiles(
        [xfile],
        text: 'Mon âge en calendrier de 13 mois !',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du partage : $e')),
      );
    }
  }

  Widget _buildResultCard() {
    return Container(
      key: _carteKey,
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E8DF).withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFB98651), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Text(
              _resultat,
              key: ValueKey(_resultat),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2F2420),
                letterSpacing: 0.3,
                shadows: [
                  Shadow(
                    color: Colors.white.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            _comparaison,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: const Color(0xFF2D2A2A),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _joursVecus,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: const Color(0xFF2D2A2A),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanetAgeSection() {
    if (_dateNaissance == null || _agesPlanetes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E8DF).withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFB98651), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Âge sur d\'autres planètes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2F2420),
            ),
          ),
          const SizedBox(height: 12),
          ..._agesPlanetes.map((planete) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    planete['nom']!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF2D2A2A),
                    ),
                  ),
                  Text(
                    '${planete['age']} ans',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF2D2A2A),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/cosmic_clock.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.12),
              BlendMode.darken,
            ),
          ),
          gradient: LinearGradient(
            colors: [
              const Color(0xFFEFE3DF),
              const Color(0xFFCAD7E4),
              const Color(0xFFE6D5C8),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          top: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16.0, 18.0, 16.0, 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0E3D4).withOpacity(0.84),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: const Color(0xFFB98651).withOpacity(0.9),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            'Entrez votre date de naissance :',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color: const Color(0xFF2D251F),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AboutPage(),
                        ),
                      );
                    },
                    icon: Icon(Icons.info_outline),
                    label: Text('À propos'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xE6C98B5B),
                      foregroundColor: const Color(0xFF2B1F1B),
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _pickDate,
                    icon: Icon(Icons.calendar_today),
                    label: Text('Choisir la date'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xE6C98B5B),
                      foregroundColor: const Color(0xFF2B1F1B),
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                  ),
                  SizedBox(height: 16),
                  if (_dateNaissance != null) ...[
                    Text(
                      'Date choisie : ${_formatDate(_dateNaissance!)}',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    const SizedBox(height: 24),
                    _buildResultCard(),
                    const SizedBox(height: 20),
                    _buildPlanetAgeSection(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _copierTexte,
                          icon: Icon(Icons.copy),
                          label: Text('Copier'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB9CBB7),
                            foregroundColor: const Color(0xFF24312C),
                            elevation: 0,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _partagerTexte,
                          icon: Icon(Icons.share),
                          label: Text('Texte'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB7C9D7),
                            foregroundColor: const Color(0xFF1D2C36),
                            elevation: 0,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _partagerImage,
                          icon: Icon(Icons.image),
                          label: Text('Image'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFCFB1B4),
                            foregroundColor: const Color(0xFF2D2123),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const List<String> _months = [
    'Avril',
    'Mai',
    'Juin',
    'Juillet',
    'Août',
    'Septembre',
    'Octobre',
    'Novembre',
    'Décembre',
    'Janvier',
    'Février',
    'Mars',
    'Mois 13',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('À propos'),
        backgroundColor: const Color(0xFFF1E2D6).withOpacity(0.86),
        foregroundColor: const Color(0xFF332923),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/cosmic_clock.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.10),
              BlendMode.darken,
            ),
          ),
          gradient: LinearGradient(
            colors: [
              const Color(0xFFEDE1DE),
              const Color(0xFFCDD9E6),
              const Color(0xFFE7D7C2),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3EBD9).withOpacity(0.82),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFD7B07A), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Une année plus régulière',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF3C2D29),
                        ),
                      ),
                      SizedBox(height: 14),
                      Text(
                        'Le calendrier grégorien que nous utilisons aujourd’hui est le fruit d’une longue histoire, mais il reste irrégulier : certains mois ont 28, 29, 30 ou 31 jours, et l’année ne se divise pas de façon aussi simple qu’un cycle parfait. Le calendrier de 13 mois propose une alternative plus régulière, plus lisible et plus stable.',
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color(0xFF2F2A28),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildMetricChip('28 jours', 'par mois'),
                    _buildMetricChip('13 mois', 'par année'),
                    _buildMetricChip('364 jours', 'sans irrégularité'),
                    _buildMetricChip('+1 jour', 'intercalaire'),
                  ],
                ),
                SizedBox(height: 22),
                _buildSectionHeader('Calendrier de 13 mois'),
                SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _months.map((month) {
                      return Container(
                        width: 94,
                        height: 42,
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3EAD9).withOpacity(0.82),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFD9B784).withOpacity(0.8),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            month,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF312923),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 22),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3EBD9).withOpacity(0.82),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFD7B07A), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Text(
                    'Tu ne trouves pas qu’il serait plus logique que le printemps marque le début de l’année plutôt que l’hiver ?',
                    style: TextStyle(
                      fontSize: 16,
                      color: const Color(0xFF2E2928),
                      height: 1.6,
                    ),
                  ),
                ),
                SizedBox(height: 22),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3EBD9).withOpacity(0.82),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFD7B07A), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('Pourquoi 12 mois ?'),
                      SizedBox(height: 12),
                      Text(
                        'Le calendrier grégorien a été construit dans un contexte religieux et historique très fort. Les mois héritent de la tradition romaine, et l’Église a longtemps influencé la structuration du temps liturgique. L’idée de 12 mois s’inscrit dans cette histoire, mais elle n’est pas la seule possible. Dès le XVIIIe siècle, des réformateurs ont proposé des calendriers plus réguliers pour mieux correspondre aux besoins de la vie moderne.',
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color(0xFF2E2928),
                          height: 1.6,
                        ),
                      ),
                      SizedBox(height: 14),
                      Text(
                        'Les idées de réforme du calendrier n’ont pas attendu le XXIe siècle : des projets comme le Georgian Calendar (1745), le calendrier positiviste d’Auguste Comte (1849), puis le World Calendar et l’International Fixed Calendar au XXe siècle, ont tous cherché à créer une année plus logique, plus stable et plus facile à prévoir. Le rythme de 13 mois de 28 jours est l’une des solutions les plus célèbres à cette ambition.',
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color(0xFF2E2928),
                          height: 1.6,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Le point fort du calendrier de 13 mois : il crée un système où chaque mois a la même durée, où l’année est plus uniforme et où la régularité du temps devient plus simple à vivre. C’est une manière élégante de repenser le calendrier sans partir de zéro : en gardant l’idée de cycle, mais en renforçant sa logique.',
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color(0xFF2E2928),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF2E2724),
      ),
    );
  }

  Widget _buildMetricChip(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E6DD).withOpacity(0.78),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB9B5B2).withOpacity(0.45)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF3E2E27),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: const Color(0xFF4D413E),
            ),
          ),
        ],
      ),
    );
  }
}

