#!/usr/bin/env python3
# YYavic Control Center - generates the Localizable.strings files
# Copyright (C) 2026 Yusufcan Yavic
# SPDX-License-Identifier: GPL-3.0-or-later
# Localizable.strings uretici. Anahtar = Ingilizce metin. Her dil icin tam 54 deger, ayni sirada.
import os, sys

KEYS = [
 "YYavic Control Center", "Effect", "Solid color", "Per-key",
 "Breathing", "Wave", "Random", "Rainbow", "Ripple", "Marquee", "Raindrop", "Aurora", "Fireworks",
 "None", "Red", "Orange", "Yellow", "Green", "Blue", "Teal", "Purple",
 "Right", "Left", "Up", "Down",
 "Color", "Open key editor…", "Brightness", "Profiles", "Delete", "New profile name", "Save",
 "Save permanently to the keyboard (survives restart)", "Start at login", "Effect palette", "Color %d",
 "Reset to default", "Connected · FW %@", "Keyboard controller not found", "Quit",
 "Speed", "Direction", "React when a key is pressed", "Could not set the login item: %@",
 "Per-key color",
 "Click or drag over the cells to paint; the change appears on the keyboard instantly. Painting shows which cell is which key.",
 "Brush", "Paint all", "White", "Clear", "Presets:", "Fire", "Ocean", "Night",
]
KEYS += ["Language", "Automatic (system language)"]
assert len(KEYS) == 56, len(KEYS)

L = {}

L["en"] = KEYS[:]

L["tr"] = [
 "YYavic Control Center", "Efekt", "Tek renk", "Tuş bazlı",
 "Nefes", "Dalga", "Rastgele", "Gökkuşağı", "Dalgacık", "Şerit", "Yağmur damlası", "Aurora", "Havai fişek",
 "Yok", "Kırmızı", "Turuncu", "Sarı", "Yeşil", "Mavi", "Turkuaz", "Mor",
 "Sağa", "Sola", "Yukarı", "Aşağı",
 "Renk", "Tuş editörünü aç…", "Parlaklık", "Profiller", "Sil", "Yeni profil adı", "Kaydet",
 "Klavyeye kalıcı kaydet (yeniden başlatınca da kalır)", "Oturum açılışında başlat", "Efekt paleti", "Renk %d",
 "Varsayılana dön", "Bağlı · FW %@", "Klavye denetleyicisi bulunamadı", "Çıkış",
 "Hız", "Yön", "Tuşa basınca tepki ver", "Oturum açılışı ayarlanamadı: %@",
 "Tuş bazlı renk",
 "Hücreleri tıklayarak ya da sürükleyerek boyayın; değişiklik klavyede anında görünür. Hangi hücrenin hangi tuş olduğunu boyayarak görebilirsiniz.",
 "Fırça", "Hepsini boya", "Beyaz", "Temizle", "Hazır desenler:", "Ateş", "Okyanus", "Gece",
]

L["de"] = [
 "YYavic Control Center", "Effekt", "Einfarbig", "Pro Taste",
 "Atmen", "Welle", "Zufällig", "Regenbogen", "Wellen", "Lauflicht", "Regentropfen", "Aurora", "Feuerwerk",
 "Keine", "Rot", "Orange", "Gelb", "Grün", "Blau", "Türkis", "Violett",
 "Rechts", "Links", "Hoch", "Runter",
 "Farbe", "Tasteneditor öffnen…", "Helligkeit", "Profile", "Löschen", "Neuer Profilname", "Speichern",
 "Dauerhaft auf der Tastatur speichern (bleibt nach Neustart)", "Beim Anmelden starten", "Effektpalette", "Farbe %d",
 "Auf Standard zurücksetzen", "Verbunden · FW %@", "Tastatur-Controller nicht gefunden", "Beenden",
 "Geschwindigkeit", "Richtung", "Bei Tastendruck reagieren", "Anmeldeobjekt konnte nicht festgelegt werden: %@",
 "Farbe pro Taste",
 "Klicken oder ziehen Sie über die Felder, um sie zu färben; die Änderung erscheint sofort auf der Tastatur. So sehen Sie, welches Feld welcher Taste entspricht.",
 "Pinsel", "Alle färben", "Weiß", "Leeren", "Vorlagen:", "Feuer", "Ozean", "Nacht",
]

L["fr"] = [
 "YYavic Control Center", "Effet", "Couleur unie", "Touche par touche",
 "Respiration", "Vague", "Aléatoire", "Arc-en-ciel", "Ondulation", "Défilement", "Goutte de pluie", "Aurore", "Feux d’artifice",
 "Aucune", "Rouge", "Orange", "Jaune", "Vert", "Bleu", "Turquoise", "Violet",
 "Droite", "Gauche", "Haut", "Bas",
 "Couleur", "Ouvrir l’éditeur de touches…", "Luminosité", "Profils", "Supprimer", "Nom du nouveau profil", "Enregistrer",
 "Enregistrer définitivement sur le clavier (conservé après redémarrage)", "Lancer à l’ouverture de session", "Palette d’effets", "Couleur %d",
 "Rétablir par défaut", "Connecté · FW %@", "Contrôleur du clavier introuvable", "Quitter",
 "Vitesse", "Direction", "Réagir à l’appui d’une touche", "Impossible de configurer l’ouverture de session : %@",
 "Couleur par touche",
 "Cliquez ou faites glisser sur les cellules pour les colorer ; le changement apparaît immédiatement sur le clavier. Cela montre quelle cellule correspond à quelle touche.",
 "Pinceau", "Tout colorer", "Blanc", "Effacer", "Préréglages :", "Feu", "Océan", "Nuit",
]

L["es"] = [
 "YYavic Control Center", "Efecto", "Color fijo", "Por tecla",
 "Respiración", "Onda", "Aleatorio", "Arcoíris", "Ondas", "Desfile", "Gotas de lluvia", "Aurora", "Fuegos artificiales",
 "Ninguno", "Rojo", "Naranja", "Amarillo", "Verde", "Azul", "Turquesa", "Morado",
 "Derecha", "Izquierda", "Arriba", "Abajo",
 "Color", "Abrir editor de teclas…", "Brillo", "Perfiles", "Eliminar", "Nombre del nuevo perfil", "Guardar",
 "Guardar de forma permanente en el teclado (se conserva al reiniciar)", "Abrir al iniciar sesión", "Paleta de efectos", "Color %d",
 "Restablecer valores", "Conectado · FW %@", "No se encontró el controlador del teclado", "Salir",
 "Velocidad", "Dirección", "Reaccionar al pulsar una tecla", "No se pudo configurar el elemento de inicio: %@",
 "Color por tecla",
 "Haz clic o arrastra sobre las celdas para pintarlas; el cambio aparece al instante en el teclado. Así verás qué celda corresponde a cada tecla.",
 "Pincel", "Pintar todo", "Blanco", "Borrar", "Preajustes:", "Fuego", "Océano", "Noche",
]

L["it"] = [
 "YYavic Control Center", "Effetto", "Tinta unita", "Per tasto",
 "Respiro", "Onda", "Casuale", "Arcobaleno", "Increspatura", "Scorrimento", "Goccia di pioggia", "Aurora", "Fuochi d’artificio",
 "Nessuno", "Rosso", "Arancione", "Giallo", "Verde", "Blu", "Turchese", "Viola",
 "Destra", "Sinistra", "Su", "Giù",
 "Colore", "Apri editor dei tasti…", "Luminosità", "Profili", "Elimina", "Nome del nuovo profilo", "Salva",
 "Salva in modo permanente sulla tastiera (resta dopo il riavvio)", "Avvia al login", "Tavolozza degli effetti", "Colore %d",
 "Ripristina predefiniti", "Connesso · FW %@", "Controller della tastiera non trovato", "Esci",
 "Velocità", "Direzione", "Reagisci alla pressione di un tasto", "Impossibile impostare l’elemento di login: %@",
 "Colore per tasto",
 "Fai clic o trascina sulle celle per colorarle; la modifica appare subito sulla tastiera. Così vedi quale cella corrisponde a quale tasto.",
 "Pennello", "Colora tutto", "Bianco", "Cancella", "Predefiniti:", "Fuoco", "Oceano", "Notte",
]

L["pt-BR"] = [
 "YYavic Control Center", "Efeito", "Cor única", "Por tecla",
 "Respiração", "Onda", "Aleatório", "Arco-íris", "Ondulação", "Letreiro", "Gotas de chuva", "Aurora", "Fogos de artifício",
 "Nenhum", "Vermelho", "Laranja", "Amarelo", "Verde", "Azul", "Turquesa", "Roxo",
 "Direita", "Esquerda", "Para cima", "Para baixo",
 "Cor", "Abrir editor de teclas…", "Brilho", "Perfis", "Excluir", "Nome do novo perfil", "Salvar",
 "Salvar permanentemente no teclado (permanece após reiniciar)", "Abrir ao iniciar sessão", "Paleta de efeitos", "Cor %d",
 "Restaurar padrão", "Conectado · FW %@", "Controlador do teclado não encontrado", "Sair",
 "Velocidade", "Direção", "Reagir ao pressionar uma tecla", "Não foi possível configurar o item de login: %@",
 "Cor por tecla",
 "Clique ou arraste sobre as células para pintá-las; a alteração aparece na hora no teclado. Assim você vê qual célula é qual tecla.",
 "Pincel", "Pintar tudo", "Branco", "Limpar", "Predefinições:", "Fogo", "Oceano", "Noite",
]

L["pt-PT"] = [
 "YYavic Control Center", "Efeito", "Cor única", "Por tecla",
 "Respiração", "Onda", "Aleatório", "Arco-íris", "Ondulação", "Letreiro", "Gotas de chuva", "Aurora", "Fogo de artifício",
 "Nenhum", "Vermelho", "Laranja", "Amarelo", "Verde", "Azul", "Turquesa", "Roxo",
 "Direita", "Esquerda", "Para cima", "Para baixo",
 "Cor", "Abrir editor de teclas…", "Brilho", "Perfis", "Eliminar", "Nome do novo perfil", "Guardar",
 "Guardar permanentemente no teclado (mantém-se após reiniciar)", "Abrir ao iniciar sessão", "Paleta de efeitos", "Cor %d",
 "Repor predefinições", "Ligado · FW %@", "Controlador do teclado não encontrado", "Sair",
 "Velocidade", "Direção", "Reagir ao premir uma tecla", "Não foi possível definir o item de início: %@",
 "Cor por tecla",
 "Clique ou arraste sobre as células para as pintar; a alteração aparece de imediato no teclado. Assim vê qual célula corresponde a cada tecla.",
 "Pincel", "Pintar tudo", "Branco", "Limpar", "Predefinições:", "Fogo", "Oceano", "Noite",
]

L["ru"] = [
 "YYavic Control Center", "Эффект", "Один цвет", "По клавишам",
 "Дыхание", "Волна", "Случайно", "Радуга", "Рябь", "Бегущая строка", "Капли дождя", "Аврора", "Фейерверк",
 "Нет", "Красный", "Оранжевый", "Жёлтый", "Зелёный", "Синий", "Бирюзовый", "Фиолетовый",
 "Вправо", "Влево", "Вверх", "Вниз",
 "Цвет", "Открыть редактор клавиш…", "Яркость", "Профили", "Удалить", "Название нового профиля", "Сохранить",
 "Сохранить в клавиатуре (останется после перезагрузки)", "Запускать при входе", "Палитра эффектов", "Цвет %d",
 "Сбросить настройки", "Подключено · FW %@", "Контроллер клавиатуры не найден", "Выйти",
 "Скорость", "Направление", "Реагировать на нажатие клавиши", "Не удалось настроить автозапуск: %@",
 "Цвет по клавишам",
 "Нажимайте или проводите по ячейкам, чтобы закрасить их; изменение сразу видно на клавиатуре. Так можно понять, какая ячейка соответствует какой клавише.",
 "Кисть", "Закрасить всё", "Белый", "Очистить", "Шаблоны:", "Огонь", "Океан", "Ночь",
]

L["cs"] = [
 "YYavic Control Center", "Efekt", "Jedna barva", "Po klávesách",
 "Dýchání", "Vlna", "Náhodně", "Duha", "Vlnky", "Běžící text", "Dešťové kapky", "Polární záře", "Ohňostroj",
 "Žádná", "Červená", "Oranžová", "Žlutá", "Zelená", "Modrá", "Tyrkysová", "Fialová",
 "Doprava", "Doleva", "Nahoru", "Dolů",
 "Barva", "Otevřít editor kláves…", "Jas", "Profily", "Smazat", "Název nového profilu", "Uložit",
 "Trvale uložit do klávesnice (zůstane po restartu)", "Spustit při přihlášení", "Paleta efektů", "Barva %d",
 "Obnovit výchozí", "Připojeno · FW %@", "Řadič klávesnice nebyl nalezen", "Ukončit",
 "Rychlost", "Směr", "Reagovat na stisk klávesy", "Položku přihlášení se nepodařilo nastavit: %@",
 "Barva po klávesách",
 "Kliknutím nebo tažením po buňkách je obarvíte; změna se okamžitě projeví na klávesnici. Tak poznáte, která buňka odpovídá které klávese.",
 "Štětec", "Obarvit vše", "Bílá", "Vymazat", "Předvolby:", "Oheň", "Oceán", "Noc",
]

L["da"] = [
 "YYavic Control Center", "Effekt", "Én farve", "Pr. tast",
 "Åndedræt", "Bølge", "Tilfældig", "Regnbue", "Krusninger", "Løbende lys", "Regndråber", "Nordlys", "Fyrværkeri",
 "Ingen", "Rød", "Orange", "Gul", "Grøn", "Blå", "Turkis", "Lilla",
 "Højre", "Venstre", "Op", "Ned",
 "Farve", "Åbn tasteeditor…", "Lysstyrke", "Profiler", "Slet", "Nyt profilnavn", "Gem",
 "Gem permanent på tastaturet (bevares efter genstart)", "Start ved login", "Effektpalet", "Farve %d",
 "Nulstil til standard", "Tilsluttet · FW %@", "Tastaturcontroller ikke fundet", "Afslut",
 "Hastighed", "Retning", "Reager når en tast trykkes", "Loginobjektet kunne ikke indstilles: %@",
 "Farve pr. tast",
 "Klik eller træk over cellerne for at male dem; ændringen vises straks på tastaturet. Sådan kan du se, hvilken celle der er hvilken tast.",
 "Pensel", "Mal alle", "Hvid", "Ryd", "Forudindstillinger:", "Ild", "Hav", "Nat",
]

L["nb"] = [
 "YYavic Control Center", "Effekt", "Én farge", "Per tast",
 "Pust", "Bølge", "Tilfeldig", "Regnbue", "Krusninger", "Løpende lys", "Regndråper", "Nordlys", "Fyrverkeri",
 "Ingen", "Rød", "Oransje", "Gul", "Grønn", "Blå", "Turkis", "Lilla",
 "Høyre", "Venstre", "Opp", "Ned",
 "Farge", "Åpne tasteeditor…", "Lysstyrke", "Profiler", "Slett", "Nytt profilnavn", "Lagre",
 "Lagre permanent på tastaturet (beholdes etter omstart)", "Start ved pålogging", "Effektpalett", "Farge %d",
 "Tilbakestill til standard", "Tilkoblet · FW %@", "Fant ikke tastaturkontrolleren", "Avslutt",
 "Hastighet", "Retning", "Reager når en tast trykkes", "Kunne ikke angi påloggingsobjektet: %@",
 "Farge per tast",
 "Klikk eller dra over cellene for å male dem; endringen vises umiddelbart på tastaturet. Slik ser du hvilken celle som er hvilken tast.",
 "Pensel", "Mal alle", "Hvit", "Tøm", "Forhåndsinnstillinger:", "Ild", "Hav", "Natt",
]

L["sv"] = [
 "YYavic Control Center", "Effekt", "En färg", "Per tangent",
 "Andning", "Våg", "Slumpmässig", "Regnbåge", "Krusning", "Löpande ljus", "Regndroppar", "Norrsken", "Fyrverkerier",
 "Ingen", "Röd", "Orange", "Gul", "Grön", "Blå", "Turkos", "Lila",
 "Höger", "Vänster", "Upp", "Ned",
 "Färg", "Öppna tangenteditorn…", "Ljusstyrka", "Profiler", "Ta bort", "Nytt profilnamn", "Spara",
 "Spara permanent i tangentbordet (finns kvar efter omstart)", "Starta vid inloggning", "Effektpalett", "Färg %d",
 "Återställ standard", "Ansluten · FW %@", "Tangentbordskontrollern hittades inte", "Avsluta",
 "Hastighet", "Riktning", "Reagera när en tangent trycks", "Det gick inte att ställa in inloggningsobjektet: %@",
 "Färg per tangent",
 "Klicka eller dra över cellerna för att måla dem; ändringen syns direkt på tangentbordet. Så ser du vilken cell som är vilken tangent.",
 "Pensel", "Måla alla", "Vit", "Rensa", "Förval:", "Eld", "Hav", "Natt",
]

L["fi"] = [
 "YYavic Control Center", "Tehoste", "Yksi väri", "Näppäinkohtainen",
 "Hengitys", "Aalto", "Satunnainen", "Sateenkaari", "Väreet", "Kulkuvalo", "Sadepisarat", "Revontulet", "Ilotulitus",
 "Ei mitään", "Punainen", "Oranssi", "Keltainen", "Vihreä", "Sininen", "Turkoosi", "Violetti",
 "Oikealle", "Vasemmalle", "Ylös", "Alas",
 "Väri", "Avaa näppäineditori…", "Kirkkaus", "Profiilit", "Poista", "Uuden profiilin nimi", "Tallenna",
 "Tallenna pysyvästi näppäimistöön (säilyy uudelleenkäynnistyksessä)", "Käynnistä kirjautumisen yhteydessä", "Tehostepaletti", "Väri %d",
 "Palauta oletus", "Yhdistetty · FW %@", "Näppäimistön ohjainta ei löytynyt", "Lopeta",
 "Nopeus", "Suunta", "Reagoi näppäimen painallukseen", "Kirjautumiskohdetta ei voitu asettaa: %@",
 "Näppäinkohtainen väri",
 "Napsauta tai vedä ruutujen yli maalataksesi ne; muutos näkyy heti näppäimistössä. Näin näet, mikä ruutu vastaa mitäkin näppäintä.",
 "Sivellin", "Maalaa kaikki", "Valkoinen", "Tyhjennä", "Esiasetukset:", "Tuli", "Valtameri", "Yö",
]

L["hu"] = [
 "YYavic Control Center", "Effekt", "Egyszínű", "Billentyűnként",
 "Lélegzés", "Hullám", "Véletlen", "Szivárvány", "Fodrozódás", "Futófény", "Esőcseppek", "Sarki fény", "Tűzijáték",
 "Nincs", "Piros", "Narancs", "Sárga", "Zöld", "Kék", "Türkiz", "Lila",
 "Jobbra", "Balra", "Fel", "Le",
 "Szín", "Billentyűszerkesztő megnyitása…", "Fényerő", "Profilok", "Törlés", "Új profil neve", "Mentés",
 "Végleges mentés a billentyűzetre (újraindítás után is megmarad)", "Indítás bejelentkezéskor", "Effektpaletta", "%d. szín",
 "Alapértelmezés visszaállítása", "Csatlakoztatva · FW %@", "A billentyűzetvezérlő nem található", "Kilépés",
 "Sebesség", "Irány", "Reagálás billentyűleütésre", "A bejelentkezési elem beállítása sikertelen: %@",
 "Billentyűnkénti szín",
 "Kattintson vagy húzzon a cellákon a színezéshez; a változás azonnal megjelenik a billentyűzeten. Így látható, melyik cella melyik billentyű.",
 "Ecset", "Összes színezése", "Fehér", "Törlés", "Előbeállítások:", "Tűz", "Óceán", "Éjszaka",
]

L["pl"] = [
 "YYavic Control Center", "Efekt", "Jeden kolor", "Dla każdego klawisza",
 "Oddychanie", "Fala", "Losowo", "Tęcza", "Fale", "Przewijanie", "Krople deszczu", "Zorza", "Fajerwerki",
 "Brak", "Czerwony", "Pomarańczowy", "Żółty", "Zielony", "Niebieski", "Turkusowy", "Fioletowy",
 "W prawo", "W lewo", "W górę", "W dół",
 "Kolor", "Otwórz edytor klawiszy…", "Jasność", "Profile", "Usuń", "Nazwa nowego profilu", "Zapisz",
 "Zapisz trwale w klawiaturze (zostaje po restarcie)", "Uruchamiaj przy logowaniu", "Paleta efektów", "Kolor %d",
 "Przywróć domyślne", "Połączono · FW %@", "Nie znaleziono kontrolera klawiatury", "Zakończ",
 "Szybkość", "Kierunek", "Reaguj na naciśnięcie klawisza", "Nie udało się ustawić elementu logowania: %@",
 "Kolor dla każdego klawisza",
 "Kliknij lub przeciągnij po komórkach, aby je pomalować; zmiana jest od razu widoczna na klawiaturze. Dzięki temu zobaczysz, która komórka to który klawisz.",
 "Pędzel", "Pomaluj wszystko", "Biały", "Wyczyść", "Gotowe wzory:", "Ogień", "Ocean", "Noc",
]

L["ja"] = [
 "YYavic Control Center", "エフェクト", "単色", "キーごと",
 "ブリージング", "ウェーブ", "ランダム", "レインボー", "リップル", "マーキー", "雨粒", "オーロラ", "花火",
 "なし", "赤", "オレンジ", "黄", "緑", "青", "ティール", "紫",
 "右", "左", "上", "下",
 "カラー", "キーエディタを開く…", "明るさ", "プロファイル", "削除", "新しいプロファイル名", "保存",
 "キーボードに永続保存（再起動後も保持）", "ログイン時に起動", "エフェクトパレット", "カラー %d",
 "初期設定に戻す", "接続済み · FW %@", "キーボードコントローラが見つかりません", "終了",
 "速度", "方向", "キーを押したときに反応", "ログイン項目を設定できませんでした: %@",
 "キーごとのカラー",
 "セルをクリックまたはドラッグして塗ります。変更はすぐにキーボードに反映されます。塗ることで、どのセルがどのキーか確認できます。",
 "ブラシ", "すべて塗る", "白", "クリア", "プリセット:", "ファイア", "オーシャン", "ナイト",
]

L["ko"] = [
 "YYavic Control Center", "효과", "단색", "키별",
 "브리딩", "웨이브", "랜덤", "레인보우", "물결", "마키", "빗방울", "오로라", "불꽃놀이",
 "없음", "빨강", "주황", "노랑", "초록", "파랑", "청록", "보라",
 "오른쪽", "왼쪽", "위", "아래",
 "색상", "키 편집기 열기…", "밝기", "프로필", "삭제", "새 프로필 이름", "저장",
 "키보드에 영구 저장(재시작 후에도 유지)", "로그인 시 시작", "효과 팔레트", "색상 %d",
 "기본값으로 재설정", "연결됨 · FW %@", "키보드 컨트롤러를 찾을 수 없음", "종료",
 "속도", "방향", "키를 누르면 반응", "로그인 항목을 설정할 수 없음: %@",
 "키별 색상",
 "셀을 클릭하거나 드래그하여 칠하세요. 변경 사항이 키보드에 즉시 반영됩니다. 칠해 보면 어떤 셀이 어떤 키인지 알 수 있습니다.",
 "브러시", "모두 칠하기", "흰색", "지우기", "프리셋:", "불", "바다", "밤",
]

L["zh-Hans"] = [
 "YYavic Control Center", "灯效", "单色", "逐键",
 "呼吸", "波浪", "随机", "彩虹", "涟漪", "流光", "雨滴", "极光", "烟花",
 "无", "红色", "橙色", "黄色", "绿色", "蓝色", "青色", "紫色",
 "向右", "向左", "向上", "向下",
 "颜色", "打开按键编辑器…", "亮度", "配置文件", "删除", "新配置文件名称", "保存",
 "永久保存到键盘（重启后仍保留）", "登录时启动", "灯效调色板", "颜色 %d",
 "恢复默认", "已连接 · FW %@", "未找到键盘控制器", "退出",
 "速度", "方向", "按键时响应", "无法设置登录项：%@",
 "逐键颜色",
 "点击或拖动单元格进行涂色，更改会立即显示在键盘上。通过涂色可以看出每个单元格对应哪个按键。",
 "画笔", "全部涂色", "白色", "清除", "预设：", "火焰", "海洋", "夜晚",
]

L["zh-Hant"] = [
 "YYavic Control Center", "燈效", "單色", "逐鍵",
 "呼吸", "波浪", "隨機", "彩虹", "漣漪", "流光", "雨滴", "極光", "煙火",
 "無", "紅色", "橙色", "黃色", "綠色", "藍色", "青色", "紫色",
 "向右", "向左", "向上", "向下",
 "顏色", "開啟按鍵編輯器…", "亮度", "設定檔", "刪除", "新設定檔名稱", "儲存",
 "永久儲存至鍵盤（重新啟動後仍保留）", "登入時啟動", "燈效調色盤", "顏色 %d",
 "還原預設值", "已連線 · FW %@", "找不到鍵盤控制器", "結束",
 "速度", "方向", "按鍵時回應", "無法設定登入項目：%@",
 "逐鍵顏色",
 "點按或拖曳儲存格來上色，變更會立即顯示在鍵盤上。藉由上色可看出每個儲存格對應哪個按鍵。",
 "畫筆", "全部上色", "白色", "清除", "預設：", "火焰", "海洋", "夜晚",
]


EXTRA = {
 "en": ("Language", "Automatic (system language)"),
 "tr": ("Dil", "Otomatik (sistem dili)"),
 "de": ("Sprache", "Automatisch (Systemsprache)"),
 "fr": ("Langue", "Automatique (langue du système)"),
 "es": ("Idioma", "Automático (idioma del sistema)"),
 "it": ("Lingua", "Automatica (lingua di sistema)"),
 "pt-BR": ("Idioma", "Automático (idioma do sistema)"),
 "pt-PT": ("Idioma", "Automático (idioma do sistema)"),
 "ru": ("Язык", "Автоматически (язык системы)"),
 "cs": ("Jazyk", "Automaticky (jazyk systému)"),
 "da": ("Sprog", "Automatisk (systemsprog)"),
 "nb": ("Språk", "Automatisk (systemspråk)"),
 "sv": ("Språk", "Automatiskt (systemspråk)"),
 "fi": ("Kieli", "Automaattinen (järjestelmän kieli)"),
 "hu": ("Nyelv", "Automatikus (rendszernyelv)"),
 "pl": ("Język", "Automatycznie (język systemu)"),
 "ja": ("言語", "自動（システムの言語）"),
 "ko": ("언어", "자동(시스템 언어)"),
 "zh-Hans": ("语言", "自动（系统语言）"),
 "zh-Hant": ("語言", "自動（系統語言）"),
}
for _l, _v in EXTRA.items():
    if _l != "en":
        L[_l] = list(L[_l]) + list(_v)

# Ingilizce metin zaten anahtar; urun adi (marka) cevrilmez (anahtar = "YYavic Control Center")
APP_NAMES = {"tr": "YYavic Control Center"}

def esc(s): return s.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n")

out = sys.argv[1]
for lang, vals in L.items():
    assert len(vals) == len(KEYS), (lang, len(vals), len(KEYS))
    d = os.path.join(out, lang + ".lproj"); os.makedirs(d, exist_ok=True)
    with open(os.path.join(d, "Localizable.strings"), "w", encoding="utf-8") as f:
        f.write("/* %s */\n" % lang)
        for k, v in zip(KEYS, vals):
            f.write('"%s" = "%s";\n' % (esc(k), esc(v)))
    if lang in APP_NAMES:
        with open(os.path.join(d, "InfoPlist.strings"), "w", encoding="utf-8") as f:
            f.write('"CFBundleDisplayName" = "%s";\n"CFBundleName" = "%s";\n' % (APP_NAMES[lang], APP_NAMES[lang]))
print("languages:", " ".join(L.keys()), "| keys:", len(KEYS))
