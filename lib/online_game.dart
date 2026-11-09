import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'word_check.dart';

const onlineUrl = String.fromEnvironment('SUPABASE_URL');
const onlineKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
bool get onlineReady => onlineUrl.isNotEmpty && onlineKey.isNotEmpty;

class OnlineGamePage extends StatefulWidget {
  const OnlineGamePage({super.key});
  @override
  State<OnlineGamePage> createState() => _OnlineGamePageState();
}

class _OnlineGamePageState extends State<OnlineGamePage> {
  static const orange = Color(0xFFF57C00);
  static const categories = ['İsim','Şehir','Hayvan','Bitki','Eşya','Ülke'];
  final name = TextEditingController(text: 'Oyuncu');
  final code = TextEditingController();
  final answers = List.generate(6, (_) => TextEditingController());
  Timer? poll;
  Map<String, dynamic>? room;
  List<Map<String, dynamic>> players = [];
  bool loading = false, refreshing = false, submitted = false;
  int submittedPoints = 0, currentRound = -1;
  String? error;

  SupabaseClient get db => Supabase.instance.client;
  String get roomId => room?['id']?.toString() ?? '';
  bool get isHost => room?['owner_id'] == db.auth.currentUser?.id;
  bool get playing => room?['status'] == 'playing';
  int get seconds {
    final started = DateTime.tryParse(room?['started_at']?.toString() ?? '');
    if (started == null) return 60;
    final ms = started.add(const Duration(seconds: 60)).difference(DateTime.now()).inMilliseconds;
    return (ms / 1000).ceil().clamp(0, 60);
  }

  @override
  void initState() {
    super.initState();
    if (onlineReady) _initialize();
  }

  Future<void> _initialize() async {
    try {
      if (db.auth.currentUser == null) await db.auth.signInAnonymously();
    } catch (e) {
      if (mounted) setState(() => error = 'Anonim oturum açılamadı: $e');
    }
  }

  Future<void> _create() async {
    await _run(() async {
      final result = await db.rpc('harf_create_room', params: {'p_name': name.text.trim()});
      await _enter(Map<String, dynamic>.from(result as Map));
    });
  }

  Future<void> _join() async {
    await _run(() async {
      final result = await db.rpc('harf_join_room', params: {'p_name': name.text.trim(), 'p_code': code.text.trim().toUpperCase()});
      await _enter(Map<String, dynamic>.from(result as Map));
    });
  }

  Future<void> _enter(Map<String, dynamic> info) async {
    room = {'id': info['id'], 'code': info['code'], 'status': 'lobby'};
    await _refresh();
    poll?.cancel();
    poll = Timer.periodic(const Duration(seconds: 2), (_) => _refresh());
  }

  Future<void> _run(Future<void> Function() body) async {
    if (loading) return;
    setState(() { loading = true; error = null; });
    try {
      if (db.auth.currentUser == null) await db.auth.signInAnonymously();
      await body();
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _refresh() async {
    if (roomId.isEmpty || refreshing) return;
    refreshing = true;
    try {
      final r = await db.from('harf_rooms').select().eq('id', roomId).single();
      final p = await db.from('harf_players').select().eq('room_id', roomId).order('score', ascending: false);
      if (!mounted) return;
      final nextRound = (r['round'] as num?)?.toInt() ?? 0;
      if (nextRound != currentRound) {
        currentRound = nextRound;
        submitted = false;
        submittedPoints = 0;
        for (final c in answers) { c.clear(); }
      }
      setState(() {
        room = Map<String,dynamic>.from(r);
        players = (p as List).map((e) => Map<String,dynamic>.from(e as Map)).toList();
      });
      if (playing && seconds == 0 && !submitted) await _submit();
    } catch (e) {
      if (mounted) setState(() => error = 'Bağlantı: $e');
    } finally {
      refreshing = false;
    }
  }

  Future<void> _startRound() => _run(() async {
    await db.rpc('harf_start_round', params: {'p_room': roomId});
    await _refresh();
  });

  Future<void> _submit() async {
    if (submitted || !playing || loading) return;
    final payload = List.generate(6, (i) => WordCheck.normalize(answers[i].text));
    setState(() { submitted = true; loading = true; error = null; });
    try {
      final response = await db.rpc('harf_submit', params: {'p_room': roomId, 'p_answers': payload});
      if (mounted) setState(() => submittedPoints = (response as num).toInt());
      await _refresh();
    } catch (e) {
      if (mounted) setState(() { error = 'Cevap gönderilemedi: $e'; submitted = false; });
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    poll?.cancel();
    name.dispose();
    code.dispose();
    for (final c in answers) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.viewInsetsOf(context).bottom > 0;
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF4),
      appBar: AppBar(title: const Text('Çevrim içi Harf Yarışı'), backgroundColor: const Color(0xFFFFEBD6)),
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.all(13),
        child: !onlineReady
          ? const Center(child: Text('Çevrim içi mod henüz sunucuya bağlanmadı. Supabase projesi ve yayınlanabilir anahtar yapılandırılmalı.', textAlign: TextAlign.center))
          : Column(children: [
              if (error != null) Padding(padding: const EdgeInsets.only(bottom: 8),
                child: Text(error!, style: const TextStyle(color: Colors.red, fontSize: 12))),
              if (room == null) ...[
                const SizedBox(height: 18),
                const Text('Arkadaşlarınla aynı anda yarış', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                const SizedBox(height: 18),
                TextField(controller: name, maxLength: 18, decoration: const InputDecoration(labelText: 'Oyuncu adın', border: OutlineInputBorder())),
                const SizedBox(height: 8),
                FilledButton.icon(onPressed: loading ? null : _create, icon: const Icon(Icons.add_circle_outline), label: const Text('ODA OLUŞTUR'),
                  style: FilledButton.styleFrom(backgroundColor: orange, minimumSize: const Size(double.infinity, 48))),
                const SizedBox(height: 15),
                TextField(controller: code, textCapitalization: TextCapitalization.characters, maxLength: 6,
                  decoration: const InputDecoration(labelText: '6 haneli oda kodu', border: OutlineInputBorder())),
                OutlinedButton.icon(onPressed: loading ? null : _join, icon: const Icon(Icons.login), label: const Text('ODA KODUYLA KATIL')),
              ] else ...[
                Container(width: double.infinity, padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: orange, borderRadius: BorderRadius.circular(15)),
                  child: Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('ODA KODU: \${room!['code']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
                      Text('Tur: \${room!['round']} • Harf: \${room!['letter']}', style: const TextStyle(color: Colors.white)),
                    ])),
                    if (playing) Text('$seconds sn', style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.bold)),
                  ]),
                ),
                const SizedBox(height: 8),
                SizedBox(height: keyboard ? 34 : 75, child: ListView(scrollDirection: Axis.horizontal, children: [
                  for (final player in players)
                    Container(width: 115, margin: const EdgeInsets.only(right: 7), padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFFD4A0))),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(player['display_name'].toString(), overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        Text('\${player['score']} puan', style: const TextStyle(fontSize: 11, color: orange)),
                      ]),
                    ),
                ])),
                const SizedBox(height: 8),
                if (!playing) ...[
                  const Expanded(child: Center(child: Text('Oyuncuların katılması bekleniyor.\nOda kodunu arkadaşlarına gönder.', textAlign: TextAlign.center))),
                  if (isHost) FilledButton(onPressed: loading ? null : _startRound, child: const Text('TURU BAŞLAT')),
                ] else ...[
                  if (submitted) Padding(padding: const EdgeInsets.all(10), child: Text('Cevapların gönderildi • +$submittedPoints puan', style: const TextStyle(color: orange, fontWeight: FontWeight.bold))),
                  Expanded(child: GridView.builder(
                    itemCount: 6,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 7, mainAxisSpacing: 7, mainAxisExtent: 81),
                    itemBuilder: (context, i) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFFFD4A0)), borderRadius: BorderRadius.circular(12)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(categories[i], style: const TextStyle(color: orange, fontWeight: FontWeight.w700, fontSize: 12)),
                        TextField(controller: answers[i], enabled: !submitted && seconds > 0, style: const TextStyle(fontSize: 13),
                          textCapitalization: TextCapitalization.words, decoration: const InputDecoration(isDense: true, hintText: 'Cevap...', border: UnderlineInputBorder())),
                      ]),
                    ),
                  )),
                  if (!submitted && seconds > 0) FilledButton(onPressed: loading ? null : _submit,
                    style: FilledButton.styleFrom(backgroundColor: orange, minimumSize: const Size(double.infinity, 44)),
                    child: const Text('STOP! — GÖNDER')),
                  if (seconds == 0 && isHost) OutlinedButton(onPressed: loading ? null : _startRound, child: const Text('YENİ TUR BAŞLAT')),
                  if (seconds == 0 && !isHost) const Text('Oda sahibi yeni turu başlatabilir.'),
                ],
              ],
            ]),
      )),
    );
  }
}
