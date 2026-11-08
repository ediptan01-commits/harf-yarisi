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
  Widget card(int index, {bool keyboard = false}) => Container(
    padding: keyboard ? const EdgeInsets.fromLTRB(8, 4, 8, 2) : const EdgeInsets.fromLTRB(10, 7, 10, 4),
    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFFFD8AD)), borderRadius: BorderRadius.circular(15)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
      Row(children: [
        Icon(pictograms[index], size: keyboard ? 13 : 16, color: orange),
        const SizedBox(width: 5),
        Expanded(child: Text(categories[index], style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Color(0xFF804300)))),
        if (done) Icon(marked[index] ? Icons.check_circle : Icons.cancel_outlined, size: 14, color: marked[index] ? Colors.green : Colors.grey),
      ]),
      SizedBox(height: keyboard ? 0 : 3),
      TextField(
        controller: inputs[index],
        focusNode: nodes[index],
        enabled: running,
        textCapitalization: TextCapitalization.words,
        textInputAction: index == 5 ? TextInputAction.done : TextInputAction.next,
        onSubmitted: (_) { if(index < 5) {nodes[index+1].requestFocus();} else {FocusManager.instance.primaryFocus?.unfocus();} },
        style: TextStyle(fontSize: keyboard ? 12 : 14),
        decoration: const InputDecoration(isDense: true, hintText: 'Kelime yaz...', hintStyle: TextStyle(fontSize: 12), contentPadding: EdgeInsets.symmetric(vertical: 5), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFFD8AD))), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: orange))),
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
    final keyboard = MediaQuery.viewInsetsOf(context).bottom > 0;
    final compact = MediaQuery.sizeOf(context).height < 720;
    final filled = inputs.where((c) => c.text.trim().isNotEmpty).length;
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF4),
      resizeToAvoidBottomInset: true,
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13),
        child: Column(children: [
          SizedBox(height: keyboard ? 0 : compact ? 4 : 8),
          Row(children: [
            Container(padding: EdgeInsets.all(keyboard ? 5 : 7), decoration: BoxDecoration(color: orange, borderRadius: BorderRadius.circular(10)), child: Icon(Icons.auto_awesome, color: Colors.white, size: keyboard ? 16 : 22)),
            const SizedBox(width: 9),
            Expanded(child: Text('Harf Yarışı', style: TextStyle(fontSize: keyboard ? 18 : 21, fontWeight: FontWeight.w900, color: Color(0xFF713C00)))),
            Text('$round. TUR', style: const TextStyle(color: Color(0xFFB75D00), fontWeight: FontWeight.bold, fontSize: 12)),
          ]),
          SizedBox(height: keyboard ? 5 : 9),
          if (keyboard) Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(color: orange, borderRadius: BorderRadius.circular(13)),
            child: Row(children: [
              Text(letter, style: const TextStyle(color: Colors.white, fontSize: 29, fontWeight: FontWeight.w900)),
              const Spacer(),
              const Icon(Icons.timer_outlined, size: 16, color: Colors.white),
              Text(' $seconds sn', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(width: 18),
              const Icon(Icons.emoji_events_outlined, size: 16, color: Colors.white),
              Text(' $points', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ]),
          ) else Container(
            width: double.infinity,
            padding: EdgeInsets.all(compact ? 9 : 12),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFFAA4D), orange]), borderRadius: BorderRadius.circular(22)),
            child: Column(children: [
              Row(children: [stat('KALAN SÜRE', '$seconds', Icons.timer), const SizedBox(width: 8), stat('TOPLAM PUAN', '$points', Icons.emoji_events)]),
              const SizedBox(height: 3),
              const Text('BU TURUN HARFİ', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              Text(letter, style: TextStyle(color: Colors.white, fontSize: compact ? 40 : 50, fontWeight: FontWeight.w900, height: 1.04)),
              Text(running ? 'Bu harfle başlayan kelimeleri bul!' : done ? 'Tur tamamlandı!' : 'Başla ve harfini keşfet!', style: const TextStyle(color: Colors.white, fontSize: 11)),
              const SizedBox(height: 5),
              ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: seconds / 60, minHeight: 6, backgroundColor: Colors.white30, valueColor: const AlwaysStoppedAnimation<Color>(Colors.white))),
            ]),
          ),
          SizedBox(height: keyboard ? 5 : 10),
          Row(children: [
            const Expanded(child: Text('✍️ Cevap kartları', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF713C00)))),
            Text('$filled/6 tamamlandı', style: const TextStyle(fontSize: 11, color: Color(0xFF9A6A3B))),
          ]),
          SizedBox(height: keyboard ? 4 : 7),
          Expanded(child: LayoutBuilder(builder: (context, box) {
            final availableCardHeight = (box.maxHeight - 12) / 3;
            return GridView.builder(
            physics: const ClampingScrollPhysics(),
            itemCount: 6,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: keyboard ? 5 : 7, crossAxisSpacing: 7, mainAxisExtent: keyboard ? (availableCardHeight < 63 ? 63 : availableCardHeight) : (availableCardHeight < 83 ? 83 : availableCardHeight)),
            itemBuilder: (_, i) => card(i, keyboard: keyboard),
          );
          })),
          if(done) Padding(padding: const EdgeInsets.only(bottom: 6), child: Text('Tur puanı: +' + (marked.where((ok) => ok).length * 10).toString() + '  •  Harf kontrolü', style: const TextStyle(fontSize: 12, color: orange, fontWeight: FontWeight.bold))),
          SizedBox(height: keyboard ? 2 : 5),
          Row(children: [
            Expanded(child: FilledButton(
              onPressed: running ? null : () {if(done) setState(() => round++); begin();},
              style: FilledButton.styleFrom(backgroundColor: orange, padding: EdgeInsets.symmetric(vertical: keyboard ? 9 : 13)),
              child: Text(done ? 'SONRAKİ TUR' : 'OYUNA BAŞLA'),
            )),
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton(
              onPressed: running ? finish : null,
              style: OutlinedButton.styleFrom(foregroundColor: orange, padding: EdgeInsets.symmetric(vertical: keyboard ? 9 : 13)),
              child: const Text('■ STOP!'),
            )),
          ]),
          SizedBox(height: keyboard ? 0 : 7),
        ]),
      )),
    );
  }
}
