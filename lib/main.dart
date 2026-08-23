import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';

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
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Color(0xFF1A1A2E),
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme.apply(bodyColor: Colors.white),
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

  String _calculerProchainAnniversaire(DateTime naissance) {
    final now = DateTime.now();
    DateTime dateAnniv = DateTime(now.year, naissance.month, naissance.day);
    if (dateAnniv.isBefore(now)) {
      dateAnniv = DateTime(now.year + 1, naissance.month, naissance.day);
    }
    final joursRestants = dateAnniv.difference(now).inDays;
    return 'Prochain anniversaire (13 mois) : dans $joursRestants jours';
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
            'Âge normal : ${ageGreg[0]} ans, ${ageGreg[1]} mois, ${ageGreg[2]} jours\n'
            'Âge 13 mois : ${age13[0]} ans, ${age13[1]} mois, ${age13[2]} jours';
        _joursVecus = 'Total jours vécus : ${age13[3]} jours';
        _prochainAnniversaire = _calculerProchainAnniversaire(picked);

        _textePartage = '🎉 Mon âge en calendrier de 13 mois :\n'
            'Date de naissance : ${_formatDate(picked)}\n'
            'Résultat : $_resultat\n'
            '$_comparaison\n'
            '$_joursVecus\n'
            '$_prochainAnniversaire';
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orangeAccent.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          AnimatedSwitcher(
            duration: Duration(milliseconds: 500),
            child: Text(
              _resultat,
              key: ValueKey(_resultat),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.orangeAccent,
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            _comparaison,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          SizedBox(height: 8),
          Text(
            _joursVecus,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          SizedBox(height: 8),
          Text(
            _prochainAnniversaire,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
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
              Colors.black.withOpacity(0.35),
              BlendMode.darken,
            ),
          ),
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
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
                  Text(
                    'Entrez votre date de naissance :',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _pickDate,
                    icon: Icon(Icons.calendar_today),
                    label: Text('Choisir la date'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  if (_dateNaissance != null) ...[
                    Text(
                      'Date choisie : ${_formatDate(_dateNaissance!)}',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    SizedBox(height: 24),
                    _buildResultCard(),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _copierTexte,
                          icon: Icon(Icons.copy),
                          label: Text('Copier'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.greenAccent,
                            foregroundColor: Colors.black,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _partagerTexte,
                          icon: Icon(Icons.share),
                          label: Text('Texte'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.black,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _partagerImage,
                          icon: Icon(Icons.image),
                          label: Text('Image'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pinkAccent,
                            foregroundColor: Colors.black,
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
