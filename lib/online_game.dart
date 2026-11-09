import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'word_check.dart';

const onlineUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://dmnhwypfbjlptucfxyky.supabase.co');
const onlineKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY', defaultValue: 'sb_publishable_Iepy41pyZuvfldCXhT9V6Q_NVTSVsCk');
bool get onlineReady => onlineUrl.isNotEmpty && onlineKey.isNotEmpty;

class OnlineGamePage extends StatefulWidget {
  const OnlineGamePage({super.key});
  @override
  State<OnlineGamePage> createState() => _OnlineGamePageState();
}

class _OnlineGamePageState extends State<OnlineGamePage> {
  static const orange = Color(0xFFF57C00);
  static const baseCategories = ['İsim','Şehir','Hayvan','Bitki','Eşya','Ülke'];
  List<String> get categories => (room?['round_categories'] as List?)?.map((e) => e.toString()).toList() ?? baseCategories;
  final name = TextEditingController(text: 'Oyuncu');
  final code = TextEditingController();
  final answers = List.generate(6, (_) => TextEditingController());
  Timer? poll;
  Map<String, dynamic>? room;
  List<Map<String, dynamic>> players = [];
  bool loading = false, refreshing = false, submitted = false;
  String matchMode = 'duel';
  int matchRounds = 3;
  int chosenCategory = 0;
  bool usedHint = false, usedDouble = false, usedExtra = false;
  String? hintText;
  String? doubleCategory;
  List<Map<String,dynamic>> results = [];
  int speedBonus = 0;
  String get status => room?['status']?.toString() ?? 'lobby';
  bool get finished => status == 'finished';
  int get currentGameRound => (room?['round'] as num?)?.toInt() ?? 0;
  int get maxRounds => (room?['match_rounds'] as num?)?.toInt() ?? 3;
  bool get isDuel => room?['mode'] == 'duel';
  bool get isMyTurnDone => players.any((p)=>p['user_id']==db.auth.currentUser?.id && (p['submitted_round'] as num? ?? 0) >= currentGameRound && currentGameRound>0);
  bool get allPlayersDone => players.length >= 2 && players.every((p)=>(p['submitted_round'] as num? ?? 0) >= currentGameRound);
  int submittedPoints = 0, currentRound = -1;
  String? error;

  SupabaseClient get db => Supabase.instance.client;
  String get roomId => room?['id']?.toString() ?? '';
  bool get isHost => room?['owner_id'] == db.auth.currentUser?.id;
  bool get playing => room?['status'] == 'playing';
  int get seconds {
    final started = DateTime.tryParse(room?['started_at']?.toString() ?? '');
    if (started == null) return 60;
    final me = players.where((p)=>p['user_id']==db.auth.currentUser?.id);
    final bonus = me.isNotEmpty && me.first['extra_round']==currentGameRound ? 10 : 0;
    final remaining = started.add(Duration(seconds: 60+bonus)).difference(DateTime.now()).inMilliseconds;
    return (remaining / 1000).ceil().clamp(0, 70).toInt();
  }
  int get wheelSeconds {
    final start=DateTime.tryParse(room?['started_at']?.toString() ?? '');
    return start == null ? 0 : ((start.difference(DateTime.now()).inMilliseconds)/1000).ceil().clamp(0,3).toInt();
  }
  bool get activeInput => playing && !submitted && !isMyTurnDone && wheelSeconds==0 && seconds>0;

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
      final result = await db.rpc('harf_create_room', params: {'p_name': name.text.trim(), 'p_mode': matchMode, 'p_match_rounds': matchRounds});
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
        speedBonus = 0;
        results = [];
        hintText = null;
        doubleCategory = null;
        chosenCategory = 0;
        usedHint = usedDouble = usedExtra = false;
        for (final c in answers) { c.clear(); }
      }
      setState(() {
        room = Map<String,dynamic>.from(r);
        players = (p as List).map((e) => Map<String,dynamic>.from(e as Map)).toList();
        if (isMyTurnDone) submitted = true;
      });
      if (playing && seconds == 0 && !submitted && !isMyTurnDone) await _submit();
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

  Future<void> _useJoker(String kind) => _run(() async {
    final r = await db.rpc('harf_use_joker', params: {
      'p_room':roomId, 'p_kind':kind, 'p_category':chosenCategory+1,
    });
    final data=Map<String,dynamic>.from(r as Map);
    if (!mounted) return;
    setState(() {
      if (kind=='hint') { usedHint=true; hintText=data['clue']?.toString(); }
      if (kind=='double') { usedDouble=true; doubleCategory=data['category']?.toString(); }
      if (kind=='extra') { usedExtra=true; }
    });
    await _refresh();
  });

  Future<void> _appeal(String category) => _run(() async {
    await db.rpc('harf_appeal',params:{
      'p_room':roomId,'p_round':currentGameRound,'p_category':category,
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content:Text('İtirazın inceleme listesine alındı. Puan otomatik eklenmez.')),
    );
    await _refresh();
  });

  Future<void> _shareRoomCode() async {
    await Clipboard.setData(ClipboardData(text:'Harf Yarışı oda kodum: ${room?['code']}'));
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Oda kodu kopyalandı')));
  }

  Future<void> _submit() async {
    if (submitted || !playing || loading) return;
    final payload = List.generate(6, (i) => WordCheck.normalize(answers[i].text));
    setState(() { submitted = true; loading = true; error = null; });
    try {
      final response = await db.rpc('harf_submit', params: {'p_room': roomId, 'p_answers': payload});
      if (mounted) setState(() {
        final data=Map<String,dynamic>.from(response as Map);
        submittedPoints=(data['points'] as num?)?.toInt() ?? 0;
        speedBonus=(data['bonus'] as num?)?.toInt() ?? 0;
        results=(data['results'] as List? ?? []).map((x)=>Map<String,dynamic>.from(x as Map)).toList();
      });
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
                const Text('MAÇ MODU',style:TextStyle(color:orange,fontWeight:FontWeight.bold)),
                Row(children:[
                  Expanded(child:ChoiceChip(label:const Text('⚔ Düello'),
                    selected:matchMode=='duel',onSelected:(_)=>setState(()=>matchMode='duel'))),
                  const SizedBox(width:9),
                  Expanded(child:ChoiceChip(label:const Text('👥 Arkadaş'),
                    selected:matchMode=='friends',onSelected:(_)=>setState(()=>matchMode='friends'))),
                ]),
                Row(children:[
                  const Text('Tur sayısı:  '),
                  ChoiceChip(label:const Text('3 tur'),selected:matchRounds==3,
                    onSelected:(_)=>setState(()=>matchRounds=3)),
                  const SizedBox(width:12),
                  ChoiceChip(label:const Text('5 tur'),selected:matchRounds==5,
                    onSelected:(_)=>setState(()=>matchRounds=5)),
                ]),
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
                      Text('ODA KODU: ${room!['code']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
                      Text('Tur: ${room!['round']} / $maxRounds • ${isDuel?'Düello':'Arkadaş'}',style:const TextStyle(color:Colors.white)),
                      if(playing) Text('Harf: ${room!['letter']}',style:const TextStyle(color:Colors.white,fontWeight:FontWeight.bold)),
                    ])),
                    if (playing) Column(children:[Text('$seconds sn',style:TextStyle(color:seconds<=10?Colors.red.shade900:Colors.white,fontSize:23,fontWeight:FontWeight.bold)),if(seconds<=10)const Text('SON 10!',style:TextStyle(color:Colors.white,fontSize:10,fontWeight:FontWeight.bold))]),
                    IconButton(onPressed:_shareRoomCode,icon:const Icon(Icons.copy,color:Colors.white),tooltip:'Oda kodunu kopyala'),
                  ]),
                ),
                const SizedBox(height: 8),
                SizedBox(height: keyboard ? 34 : 75, child: ListView(scrollDirection: Axis.horizontal, children: [
                  for (final player in players)
                    Container(width: 115, margin: const EdgeInsets.only(right: 7), padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFFD4A0))),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(player['display_name'].toString(), overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        Text('${player['score']} puan', style: const TextStyle(fontSize: 11, color: orange)),
                      ]),
                    ),
                ])),
                const SizedBox(height: 8),
                if (finished) ...[
                  Expanded(child:Center(child:Column(mainAxisSize:MainAxisSize.min,children:[
                    const Icon(Icons.emoji_events,color:orange,size:60),
                    const Text('MAÇ TAMAMLANDI!',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)),
                    if(players.isNotEmpty)Text('Kazanan: ${players.first['display_name']}'),
                  ]))),
                ] else if (!playing) ...[
                  Expanded(child:Center(child:Text(isDuel?'Düello için 2. oyuncuyu bekliyoruz.':'Arkadaş odasında 2–4 oyuncu yarışabilir.\nKodu paylaş ve arkadaşlarını davet et.',textAlign:TextAlign.center))),
                  if (isHost) FilledButton(onPressed: loading ? null : _startRound, child: const Text('TURU BAŞLAT')),
                ] else if(wheelSeconds>0) ...[
                  Expanded(child:Center(child:Column(mainAxisSize:MainAxisSize.min,children:[
                    TweenAnimationBuilder<double>(key:ValueKey(currentGameRound),
                      tween:Tween(begin:0,end:6.0),duration:const Duration(seconds:3),
                      builder:(context,v,child)=>Transform.rotate(angle:v,child:child),
                      child:CircleAvatar(radius:50,backgroundColor:orange,
                        child:Text('${room!['letter']}',style:const TextStyle(fontSize:50,color:Colors.white)))),
                    const SizedBox(height:12),
                    const Text('HARF ÇARKI DÖNÜYOR!',style:TextStyle(color:orange,fontWeight:FontWeight.bold)),
                  ]))),
                ] else ...[
                  if (submitted || isMyTurnDone) Padding(padding: const EdgeInsets.all(6), child: Text('Cevapların gönderildi • +$submittedPoints puan${speedBonus>0?' • HIZ +$speedBonus':''}',style:const TextStyle(color:orange,fontWeight:FontWeight.bold))),
                  Expanded(child: GridView.builder(
                    itemCount: 6,
                    gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2,crossAxisSpacing:7,mainAxisSpacing:7,mainAxisExtent:91),
                    itemBuilder: (context, i) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFFFD4A0)), borderRadius: BorderRadius.circular(12)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children:[Expanded(child:Text(categories[i],style:const TextStyle(color:orange,fontWeight:FontWeight.w700,fontSize:12))),if(results.any((r)=>r['category']==categories[i])) Icon(results.firstWhere((r)=>r['category']==categories[i])['valid']==true?Icons.check_circle:Icons.cancel_outlined,size:14,color:results.firstWhere((r)=>r['category']==categories[i])['valid']==true?Colors.green:Colors.red)]),
                        TextField(controller: answers[i], onTap:()=>setState(()=>chosenCategory=i),enabled:activeInput,style:const TextStyle(fontSize:13),
                          textCapitalization: TextCapitalization.words, decoration: const InputDecoration(isDense: true, hintText: 'Cevap...', border: UnderlineInputBorder())),
                        if(results.any((r)=>r['category']==categories[i]&&r['valid']!=true)) InkWell(onTap:()=>_appeal(categories[i]),child:const Text('İtiraz et',style:TextStyle(color:orange,fontSize:10,decoration:TextDecoration.underline))),
                      ]),
                    ),
                  )),
                  if(activeInput && !keyboard) Column(children:[
                    Text('Joker kategorisi: ${categories[chosenCategory]}',style:const TextStyle(fontSize:11,color:orange)),
                    Row(children:[
                      Expanded(child:OutlinedButton(onPressed:loading||usedHint?null:()=>_useJoker('hint'),child:const Text('💡 İpucu',style:TextStyle(fontSize:11)))),
                      Expanded(child:OutlinedButton(onPressed:loading||usedDouble?null:()=>_useJoker('double'),child:const Text('×2 Puan',style:TextStyle(fontSize:11)))),
                      Expanded(child:OutlinedButton(onPressed:loading||usedExtra?null:()=>_useJoker('extra'),child:const Text('+10 sn',style:TextStyle(fontSize:11)))),
                    ]),
                    if(hintText!=null) Text('İpucu: $hintText',style:const TextStyle(fontSize:11,color:orange)),
                  ]),
                  if(activeInput) FilledButton(onPressed: loading ? null : _submit,
                    style: FilledButton.styleFrom(backgroundColor: orange, minimumSize: const Size(double.infinity, 44)),
                    child: const Text('STOP! — GÖNDER')),
                  if ((seconds == 0 || allPlayersDone) && isHost) OutlinedButton(onPressed:loading?null:_startRound,child:Text(currentGameRound>=maxRounds?'MAÇI BİTİR':'SONRAKİ TUR')),
                  if ((seconds == 0 || allPlayersDone) && !isHost) const Text('Oda sahibi sonraki turu başlatabilir.'),
                ],
              ],
            ]),
      )),
    );
  }
}
