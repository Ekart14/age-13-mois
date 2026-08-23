import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Âge 13 Mois',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Color(0xFF1A1A2E),
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: AgeCalculatorPage(),
    );
  }
}

class AgeCalculatorPage extends StatefulWidget {
  @override
  _AgeCalculatorPageState createState() => _AgeCalculatorPageState();
}

class _AgeCalculatorPageState extends State<AgeCalculatorPage> {
  DateTime? _dateNaissance;
  String _resultat = '';
  String _comparaison = '';
  String _joursVecus = '';
  String _prochainAnniversaire = '';

  String _formatDate(DateTime date) {
    final formatter = DateFormat('EEEE d MMMM y', 'fr_FR');
    return formatter.format(date);
  }

  List<int> _calculerAge13Mois(DateTime naissance, DateTime maintenant) {
    const joursParMois = 28;
    const moisParAn = 13;
    final joursParAn = joursParMois * moisParAn;

    final dateNaissance = DateTime(naissance.year, naissance.month, naissance.day);
    final dateMaintenant = DateTime(maintenant.year, maintenant.month, maintenant.day);
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
    var dateAnniv = DateTime(now.year, naissance.month, naissance.day);
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
      setState(() {
        _dateNaissance = picked;

        final age13 = _calculerAge13Mois(picked, now);
        final ageGreg = _calculerAgeGregorien(picked, now);

        _resultat = '${age13[0]} ans, ${age13[1]} mois, ${age13[2]} jours';
        _comparaison = 'Âge normal : ${ageGreg[0]} ans, ${ageGreg[1]} mois, ${ageGreg[2]} jours\n'
            'Âge calendrier 13 mois : ${age13[0]} ans, ${age13[1]} mois, ${age13[2]} jours';
        _joursVecus = 'Total jours vécus : ${age13[3]} jours';
        _prochainAnniversaire = _calculerProchainAnniversaire(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Âge en calendrier de 13 mois'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        // Image de fond cosmique
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/cosmic_clock.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          // Voile sombre pour améliorer la lisibilité
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 60),
                  Text(
                    'Entrez votre date de naissance :',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _pickDate,
                    icon: Icon(Icons.calendar_today),
                    label: Text('Choisir la date'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 20),
                  if (_dateNaissance != null) ...[
                    Text(
                      'Date choisie : ${_formatDate(_dateNaissance!)}',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.orangeAccent.withOpacity(0.4),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.4),
                            blurRadius: 20,
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
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.orangeAccent,
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            _comparaison,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15, color: Colors.white),
                          ),
                          SizedBox(height: 10),
                          Text(
                            _joursVecus,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15, color: Colors.white),
                          ),
                        ],
                      ),
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
