import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: GamePage()));

class GamePage extends StatefulWidget {
  const GamePage({super.key});
  @override
  State<GamePage> createState() => _GamePageState();
}
class _GamePageState extends State<GamePage> with WidgetsBindingObserver {
  static const orange = Color(0xFFF57C00);
  static const categories = ['İsim', 'Şehir', 'Hayvan', 'Bitki', 'Eşya', 'Ülke'];
  static const pictograms = [Icons.person, Icons.location_city, Icons.pets, Icons.local_florist, Icons.chair, Icons.public];
  static const letters = ['A','B','C','Ç','D','E','F','G','H','İ','K','L','M','N','O','P','R','S','T','U','Y','Z'];
  final inputs = List.generate(6, (_) => TextEditingController());
  final nodes = List.generate(6, (_) => FocusNode());
  Timer? countdown;
  DateTime? deadline;
  int seconds = 60;
  int points = 0;
  int round = 1;
  String letter = '?';
  bool running = false;
  bool done = false;
  List<bool> marked = List.filled(6, false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    for (final input in inputs) { input.addListener(() { if(mounted) setState(() {}); }); }
  }
  @override
  void dispose() {
    countdown?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    for (final input in inputs) { input.dispose(); }
    for (final node in nodes) { node.dispose(); }
    super.dispose();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    if (s == AppLifecycleState.resumed) tick();
  }
  void tick() {
    if (!running || deadline == null) return;
    final milliseconds = deadline!.difference(DateTime.now()).inMilliseconds;
    if (milliseconds <= 0) {
      setState(() => seconds = 0);
      finish();
    } else {
      setState(() => seconds = (milliseconds / 1000).ceil());
    }
  }
  void begin() {
    countdown?.cancel();
    final options = letters.where((item) => item != letter).toList();
    final next = options[Random().nextInt(options.length)];
    FocusManager.instance.primaryFocus?.unfocus();
    for (final input in inputs) { input.clear(); }
    setState(() {
      letter = next;
      seconds = 60;
      running = true;
      done = false;
      marked = List.filled(6, false);
      deadline = DateTime.now().add(const Duration(seconds: 60));
    });
    countdown = Timer.periodic(const Duration(milliseconds: 250), (_) => tick());
  }
  void finish() {
    if (!running) return;
    countdown?.cancel();
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      marked = inputs.map((c) => c.text.trim().isNotEmpty && c.text.trim().toUpperCase().startsWith(letter)).toList();
      points += marked.where((ok) => ok).length * 10;
      running = false;
      done = true;
    });
  }
  Widget card(int index) => Container(
    padding: const EdgeInsets.fromLTRB(10, 9, 10, 7),
    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFFFD8AD)), borderRadius: BorderRadius.circular(15)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
      Row(children: [
        Icon(pictograms[index], size: 17, color: orange),
        const SizedBox(width: 5),
        Expanded(child: Text(categories[index], style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFF804300)))),
        if (done) Icon(marked[index] ? Icons.check_circle : Icons.cancel_outlined, size: 14, color: marked[index] ? Colors.green : Colors.grey),
      ]),
      const SizedBox(height: 3),
      TextField(
        controller: inputs[index],
        focusNode: nodes[index],
        enabled: running,
        textCapitalization: TextCapitalization.words,
        textInputAction: index == 5 ? TextInputAction.done : TextInputAction.next,
        onSubmitted: (_) { if(index < 5) {nodes[index+1].requestFocus();} else {FocusManager.instance.primaryFocus?.unfocus();} },
        style: const TextStyle(fontSize: 14),
        decoration: const InputDecoration(isDense: true, hintText: 'Kelime yaz...', hintStyle: TextStyle(fontSize: 12), contentPadding: EdgeInsets.symmetric(vertical: 8), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFFD8AD))), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: orange))),
      ),
    ]),
  );
  Widget stat(String label, String value, IconData icon) => Expanded(child: Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
    child: Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 13, color: Colors.white),
        const SizedBox(width: 4),
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
      ]),
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900)),
    ]),
  ));
  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).height < 720;
    final filled = inputs.where((c) => c.text.trim().isNotEmpty).length;
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF4),
      resizeToAvoidBottomInset: true,
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13),
        child: Column(children: [
          SizedBox(height: compact ? 4 : 12),
          Row(children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: orange, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.auto_awesome, color: Colors.white)),
            const SizedBox(width: 9),
            const Expanded(child: Text('Harf Yarışı', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900, color: Color(0xFF713C00)))),
            Chip(label: Text('$round. TUR'), backgroundColor: const Color(0xFFFFE8CC), side: BorderSide.none),
          ]),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(compact ? 12 : 15),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFFAA4D), orange]), borderRadius: BorderRadius.circular(22)),
            child: Column(children: [
              Row(children: [stat('KALAN SÜRE', '$seconds', Icons.timer), const SizedBox(width: 8), stat('TOPLAM PUAN', '$points', Icons.emoji_events)]),
              const SizedBox(height: 9),
              const Text('BU TURUN HARFİ', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              Text(letter, style: TextStyle(color: Colors.white, fontSize: compact ? 51 : 68, fontWeight: FontWeight.w900, height: 1.04)),
              Text(running ? 'Bu harfle başlayan kelimeleri bul!' : done ? 'Tur tamamlandı!' : 'Başla ve harfini keşfet!', style: const TextStyle(color: Colors.white, fontSize: 11)),
              const SizedBox(height: 9),
              ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: seconds / 60, minHeight: 6, backgroundColor: Colors.white30, valueColor: const AlwaysStoppedAnimation<Color>(Colors.white))),
            ]),
          ),
          const SizedBox(height: 12),
          Row(children: [
            const Expanded(child: Text('✍️ Cevap kartları', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF713C00)))),
            Text('$filled/6 tamamlandı', style: const TextStyle(fontSize: 11, color: Color(0xFF9A6A3B))),
          ]),
          const SizedBox(height: 8),
          Expanded(child: GridView.builder(
            physics: const ClampingScrollPhysics(),
            itemCount: 6,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.53),
            itemBuilder: (_, i) => card(i),
          )),
          if(done) Padding(padding: const EdgeInsets.only(bottom: 6), child: Text('Tur puanı: +' + (marked.where((ok) => ok).length * 10).toString() + '  •  Harf kontrolü', style: const TextStyle(fontSize: 12, color: orange, fontWeight: FontWeight.bold))),
          const SizedBox(height: 5),
          Row(children: [
            Expanded(child: FilledButton(
              onPressed: running ? null : () {if(done) setState(() => round++); begin();},
              style: FilledButton.styleFrom(backgroundColor: orange, padding: const EdgeInsets.symmetric(vertical: 13)),
              child: Text(done ? 'SONRAKİ TUR' : 'OYUNA BAŞLA'),
            )),
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton(
              onPressed: running ? finish : null,
              style: OutlinedButton.styleFrom(foregroundColor: orange, padding: const EdgeInsets.symmetric(vertical: 13)),
              child: const Text('■ STOP!'),
            )),
          ]),
          const SizedBox(height: 7),
        ]),
      )),
    );
  }
}
