--- Heavily inspired by
--- https://github.com/dtr2300/nvim/blob/main/lua/config/plugins/alpha.lua

---@return table
local function layout()
  ---@param sc string
  ---@param txt string
  ---@param keybind string?
  ---@param keybind_opts table?
  ---@param opts table?
  ---@return table
  local function button(sc, txt, keybind, keybind_opts, opts)
    local def_opts = {
      cursor = 3,
      align_shortcut = 'right',
      hl_shortcut = 'AlphaButtonShortcut',
      hl = 'AlphaButton',
      width = 75,
      position = 'center',
    }
    opts = opts and vim.tbl_extend('force', def_opts, opts) or def_opts
    opts.shortcut = sc
    local sc_ = sc:gsub('%s', ''):gsub('SPC', '<Leader>')
    local on_press = function()
      local key = vim.api.nvim_replace_termcodes(keybind or sc_ .. '<Ignore>', true, false, true)
      vim.api.nvim_feedkeys(key, 't', false)
    end
    if keybind then
      keybind_opts = vim.F.if_nil(keybind_opts, { noremap = true, silent = true, nowait = true })
      opts.keymap = { 'n', sc_, keybind, keybind_opts }
    end
    return { type = 'button', val = txt, on_press = on_press, opts = opts }
  end

  -- https://github.com/goolord/alpha-nvim/issues/105
  local lazycache = setmetatable({}, {
    __newindex = function(table, index, fn)
      assert(type(fn) == 'function')
      getmetatable(table)[index] = fn
    end,
    __call = function(table, index)
      return function()
        return table[index]
      end
    end,
    __index = function(table, index)
      local fn = getmetatable(table)[index]
      if fn then
        local value = fn()
        rawset(table, index, value)
        return value
      end
    end,
  })

  ---@return string
  lazycache.info = function()
    local plugins = #vim.tbl_keys(require('lazy').plugins())
    local v = vim.version()
    local datetime = os.date ' %d.%m.%Y   %H:%M'
    local platform = vim.fn.has 'win32' == 1 and '' or ''
    return string.format('󰂖 %d  %s %d.%d.%d  %s', plugins, platform, v.major, v.minor, v.patch, datetime)
  end

  ---@return table
  lazycache.menu = function()
    return {
      button('SPC s .', '󰈢  Search recently opened'),
      button('SPC s f', '  Search file'),
      button('SPC s g', '  Search by grep'),
      button('\\', '  File tree'),
      button('n', '  New file', '<Cmd>ene<CR>'),
      button('p', '󰂖  Plugins', '<Cmd>Lazy<CR>'),
      button('q', '󰅚  Quit', '<Cmd>qa<CR>'),
    }
  end

  ---@return table
  lazycache.mru = function()
    local result = {}
    for _, filename in ipairs(vim.v.oldfiles) do
      if vim.loop.fs_stat(filename) ~= nil then
        local icon, hl = require('nvim-web-devicons').get_icon(filename, vim.fn.fnamemodify(filename, ':e'))
        local filename_short = string.sub(vim.fn.fnamemodify(filename, ':t'), 1, 30)
        table.insert(
          result,
          button(
            tostring(#result + 1),
            string.format('%s  %s', icon or '', filename_short),
            string.format('<Cmd>e %s<CR>', filename),
            nil,
            { hl = { { hl or 'Normal', 0, 3 }, { 'Normal', 5, #filename_short + 5 } } }
          )
        )
        if #result == 5 then
          break
        end
      end
    end
    return result
  end

  ---@return table
  lazycache.fortune = function()
    return require 'alpha.fortune' {
      max_width = 75,
      fortune_list = {
        { 'Lepiej zaliczać się do niektórych, niż do wszystkich.', '', '- Andrzej Sapkowski, Krew elfów' },
        {
          'O miłości wiemy niewiele. Z miłością jest jak z gruszką. Gruszka jest słodka i ma kształt. Spróbujcie zdefiniować kształt gruszki.',
          '',
          '- Andrzej Sapkowski, Ostatnie życzenie',
        },
        {
          'Lepiej bez celu iść naprzód niż bez celu stać w miejscu, a z pewnością o niebo lepiej, niż bez celu się cofać.',
          '',
          '- Andrzej Sapkowski, Wieża jaskółki',
        },
        {
          'Wiadomym jest mi, że masz lat blisko czterdzieści, wyglądasz na blisko trzydzieści, wyobrażasz sobie, że masz nieco ponad dwadzieścia, a postępujesz tak jakbyś miał niecałe dziesięć.',
          '',
          '- Andrzej Sapkowski, Krew elfów',
        },
        {
          '– Na moim sihillu – warknął Zoltan, obnażając miecz – wyryte jest starodawnymi krasnoludzkimi runami prastare krasnoludzkie zaklęcie. Niech no jeno który ghul zbliży się na długość klingi, popamięta mnie. O, popatrzcie. ',
          '– Ha – zaciekawił się Jaskier, który właśnie zbliżył się do nich. – Więc to są te słynne tajne runy krasnoludów? Co głosi ten napis?',
          '– „Na pohybel skurwysynom!”',
          '',
          '- Andrzej Sapkowski, Chrzest ognia',
        },
        { 'Cicho, cicho dzieci. To nie demony, nie diabły... Gorzej. To ludzie.', '', '- Andrzej Sapkowski, Wieża jaskółki' },
        { 'Mylisz niebo z gwiazdami odbitymi nocą na powierzchni stawu.', '', '- Andrzej Sapkowski, Wieża jaskółki' },
        {
          'Źle czy dobrze, okaże się później. Ale trzeba działać, śmiało chwytać życie za grzywę. Wierz mi, malutka, żałuje się wyłącznie bezczynności, niezdecydowania, wahania. Czynów i decyzji, choć niekiedy przynoszą smutek i żal, nie żałuje się.',
          '',
          '- Andrzej Sapkowski, Czas pogardy',
        },
        { 'Ten, kto raz nie złamie w sobie tchórzostwa, będzie umierał ze strachu do końca swoich dni.', '', '- Andrzej Sapkowski, Pani Jeziora' },
        {
          'Nie malkonteńć, Geralt. I przestań się burmuszyć, bo na widok twojej gęby przydrożne grzyby same się marynują.',
          '',
          '- Andrzej Sapkowski, Pani Jeziora',
        },
        {
          'Tam gdzie dziś piętrzą się góry, będą kiedyś morza tam gdzie dziś wełnią się morza, będą kiedyś pustynie. A głupota pozostanie głupotą.',
          '',
          '- Andrzej Sapkowski, Krew elfów',
        },
        {
          'Błędy też się dla mnie liczą. Nie wykreślam ich ani z życia, ani z pamięci. I nigdy nie winię za nie innych.',
          '',
          '- Andrzej Sapkowski, Krew elfów',
        },
        { 'A potem świat znowu zaczął istnieć, ale istniał zupełnie inaczej.', '', '- Andrzej Sapkowski, Ostatnie życzenie' },
        {
          'Ty jesteś wiedźminem anachronicznym, a ja wiedźminem nowoczesnym, idącym z duchem czasu. Dlatego ty wkrótce będziesz bezrobotny, a ja będę prosperował. Strzyg, wiwern, endriag i wilkołaków wkrótce nie będzie już na świecie. A skurwysyny będą zawsze.',
          '',
          '- Andrzej Sapkowski, Czas pogardy',
        },
        {
          '– Kompania mi się trafiła – podjął Geralt, kręcąc głową. – Towarzysze broni! Drużyna bohaterów! Nic, tylko ręce załamać. Wierszokleta z lutnią. Dzikie i pyskate pół driady, pół baby. Wampir, któremu idzie na pięćdziesiąty krzyżyk. I cholerny Nilfgaardczyk, który upiera się, że nie jest Nilfgaardczykiem.',
          '– A na czele drużyny wiedźmin, chory na wyrzuty sumienia, bezsiłę i niemożność podjęcia decyzji – dokończył spokojnie Regis. – Zaiste, proponuję podróżować incognito, by nie wzbudzać sensacji.',
          '– I śmiechu – dodała Milva.',
          '',
          '- Andrzej Sapkowski, Chrzest ognia',
        },
        {
          'Jesteś kobietą, o której mężczyzna może tylko marzyć. Moją, tylko moją winą jest, że nie mam natury marzyciela.',
          '',
          '- Andrzej Sapkowski, Pani Jeziora',
        },
        {
          'Czy rozumiesz teraz, czym jest neutralność, która tak cię porusza? Być neutralnym to nie znaczy być obojętnym i nieczułym. Nie trzeba zabijać w sobie uczuć. Wystarczy zabić w sobie nienawiść.',
          '',
          '- Andrzej Sapkowski, Krew elfów',
        },
        {
          'A ja myślę, że całe zło tego świata bierze się z myślenia. Zwłaszcza w wykonaniu ludzi całkiem ku temu nie mających predyspozycji.',
          '',
          '- Andrzej Sapkowski, Narrenturm',
        },
        { 'Przychodzi kiedyś taki czas, gdy trzeba albo srać albo oswobodzić wychodek.', '', '- Andrzej Sapkowski, Pani Jeziora' },
        {
          '– Zło to zło, Stregoborze – rzekł poważnie wiedźmin wstając. – Mniejsze, większe, średnie, wszystko jedno, proporcje są umowne a granice zatarte. Nie jestem świątobliwym pustelnikiem, nie samo dobro czyniłem w życiu. Ale jeżeli mam wybierać pomiędzy jednym złem a drugim, to wolę nie wybierać wcale.',
          '',
          '- Andrzej Sapkowski, Ostatnie życzenie',
        },
        {
          'Bo w każdym z nas jest Chaos i Ład, Dobro i Zło. Ale nad tym można i trzeba zapanować. Trzeba się tego nauczyć.',
          '',
          '- Andrzej Sapkowski, Krew elfów',
        },
        {
          'O miłości wiemy niewiele. Z miłością jest jak z gruszką. Gruszka jest słodka i ma kształt. Spróbujcie zdefiniować kształt gruszki.',
          '',
          '- Andrzej Sapkowski, Czas pogardy',
        },
        {
          'W każdym momencie, w każdej chwili, w każdym zdarzeniu kryją się przeszłość, przyszłość i teraźniejszość. W każdej chwili kryje się wieczność. Każde odejście jest zarazem powrotem, każde pożegnanie powitaniem, każdy powrót rozstaniem. Wszystko jest jednocześnie początkiem i końcem.',
          '',
          '- Andrzej Sapkowski, Pani Jeziora',
        },
        { 'Musimy żyć. Żyć tak, by później nikogo nie musieć prosić o wybaczenie.', '', '- Andrzej Sapkowski, Krew elfów' },
        {
          'Każdy sen, ten czarowny i piękny, zbyt długo śniony zamienia się w koszmar. A z takiego budzimy się z krzykiem',
          '',
          '- Andrzej Sapkowski, Pani Jeziora',
        },
        {
          'Ludzie (...) lubią wymyślać potwory i potworności. Sami sobie wydają się wtedy mniej potworni (...) Wtedy jakoś lżej im się robi na sercu. I łatwiej im żyć.',
          '',
          '- Andrzej Sapkowski, Ostatnie życzenie',
        },
        {
          '– Będę czujny – westchnął. – Ale nie sądzę, żeby twój wytrawny gracz był w stanie mnie',
          'zaskoczyć. Nie po tym, co ja tu przeszedłem. Rzucili się na mnie szpiedzy, opadły wymierające gady i',
          'gronostaje. Nakarmiono mnie nie istniejącym kawiorem. Nie gustujące w mężczyznach nimfomanki',
          'podawały w wątpliwość moją męskość, groziły gwałtem na jeżu, straszyły ciążą, ba, nawet orgazmem,',
          'i to takim, któremu nie towarzyszą rytualne ruchy. Brrr...',
          '– Piłeś',
          '',
          '- Andrzej Sapkowski, Czas pogardy',
        },
        { 'Strzyg, wiwern, endriag i wilkołaków wkrótce nie będzie na świecie. A skurwysyny będą zawsze.', '', '- Andrzej Sapkowski, Czas pogardy' },
        { '– Miecz. Na plecach. Dlaczego masz na plecach miecz? ', '– Bo wiosło mi ukradli.', '', '- Andrzej Sapkowski, Krew elfów' },
        {
          'Niektórzy twierdzą, że każda, absolutnie każda rzecz na swiecie ma swoją cenę. To nieprawda. Są rzeczy, które ceny nie mają, są bezcenne. Najłatwiej poznać takie rzeczy po tym, że raz utracone, są utracone na zawsze.',
          '',
          '- Andrzej Sapkowski, Chrzest ognia',
        },
        {
          'Jeśli ma się przyjaciół, a mimo to wszystko się traci, jest oczywiste, że przyjaciele ponoszą winę. Za to, co uczynili, względnie za to, czego nie uczynili. Za to, że nie wiedzieli, co należy uczynić.',
          '',
          '- Andrzej Sapkowski, Ostatnie życzenie',
        },
        { 'Jeśli cel przyświeca, sposób musi się znaleźć.', '', '- Andrzej Sapkowski, Pani Jeziora' },
        {
          'Strzeżcie się rozczarowań, bo pozory mylą. Takimi, jakimi wydają się być, rzeczy są rzadko. A kobiety nigdy.',
          '',
          '- Andrzej Sapkowski, Sezon burz',
        },
        { 'Miłość kpi sobie z rozsądku. I w tym jej urok i piękno.', '', '- Andrzej Sapkowski, Pani Jeziora' },
        { 'Jedyną czynnością, która dobrze wychodzi samotnym, jest samogwałt.', '', '- Andrzej Sapkowski, Chrzest ognia' },
        {
          'Tak, tak – westchnął ponownie Jaskier. – Świat się zmienia, słońce zachodzi, a wódka się kończy.',
          '',
          '- Andrzej Sapkowski, Ostatnie Życzenie. Miecz Przeznaczenia',
        },
        { 'Rycerz pieprzony chędożony! Herbowy! Trzy lwy w tarczy – dwa srają, a trzeci warczy.', '', '- Andrzej Sapkowski, Krew elfów' },
        { 'Świat się zmienia, słońce zachodzi a wódka się kończy', '', '- Andrzej Sapkowski, Ostatnie życzenie' },
        { 'Nie drwij z cudzej religii, ani to ładne, ani grzeczne, ani... bezpieczne.', '', '- Andrzej Sapkowski, Krew elfów' },
        { '– Zostaliście, więc bez pociechy duchowej?', '– Jest wódka.', '', '- Andrzej Sapkowski, Boży bojownicy' },
        { 'Pomyliłaś się. Pomyliłaś niebo z gwiazdami odbitymi nocą na powierzchni stawu.', '', '- Andrzej Sapkowski, Krew elfów' },
        {
          '– Mój rumak nazywa się Pegaz. ',
          '– Jakżeby inaczej. Wiesz co? Moją elfią kobyłę też jakoś nazwiemy. Hmmm... ',
          '– Może Płotka? – zakpił trubadur.',
          '– Płotka – zgodził się wiedźmin. – Ładnie.',
          '– Geralt?',
          '– Słucham.',
          '– Czy miałeś w życiu konia, który nie nazywał się Płotka?',
          '– Nie – odrzekł wiedźmin po chwili zastanowienia. – Nie miałem.',
          '',
          '- Andrzej Sapkowski, Chrzest ognia',
        },
        {
          'Gówno i kapusta zawsze w parze idą – rzekł sentencjonalnie Percival Schuttenbach. – Jedno popędza drugie. Perpetuum mobile.',
          '',
          '- Andrzej Sapkowski, Chrzest ognia',
        },
        {
          'opatrz jeno – rzekł Szarlej, zatrzymując się. – Kościół, karczma, bordel, a w środku między nimi kupa gówna. Oto parabola ludzkiego żywota.',
          '',
          '- Andrzej Sapkowski, Narrenturm',
        },
        { 'Poglądy są jak dupa, każdy jakieś ma, ale po co od razu pokazywać...', '', '- Andrzej Sapkowski, Lux perpetua' },
        { 'Pomyliłeś niebo z gwiazdami odbitymi nocą na powierzchni stawu.', '', '- Andrzej Sapkowski, Czas pogardy' },
        {
          'Potrzebuję dla mojej ballady tytułu. Ładnego tytułu.',
          '– Może „Kraniec świata”?',
          '– Banalne (...) Hm... Niech pomyślę... „Tam, gdzie...” Cholera. „Tam, gdzie...”',
          '– Dobranoc – powiedział diabeł.',
          '',
          '- Andrzej Sapkowski, Ostatnie życzenie',
        },
        {
          'Dobrze jest odczuwać strach. Odczuwasz strach, znaczy, jest się czego bać, bądź więc czujny. Strachu nie trzeba pokonywać. Wystarczy mu nie ulegać. I warto uczyć się odeń.',
          '',
          '- Andrzej Sapkowski, Sezon burz',
        },
        {
          '– Tak? No to powiedz, o czym oni rozmawiają? (…)',
          '– Wyjrzyj jeszcze raz przez dziurę i zobacz, co robią.',
          '– Hmm… (…) Pani Yennefer stoi przy wierzbie… obrywa listki i bawi się swoją gwiazdą… nic nie mówi i nie patrzy w ogóle na Geralta… a Geralt stoi obok. Spuścił głowę. I coś mówi. Nie, milczy. Oj, minę ma… ależ dziwną ma minę…',
          '– Dziecinnie proste. (…) On właśnie prosi ją, by mu wybaczyła jego rozmaite głupie słowa i uczynki. Przeprasza ją za niecierpliwość, za brak wiary i nadziei, za upór, za zawziętość, za dąsy i pozy niegodne mężczyzny. Przeprasza ją za to, czego kiedyś nie rozumiał, za to, czego nie chciał zrozumieć… (…) Przeprasza ją za to, co zrozumiał dopiero teraz (…) Za to, co chciałby zrozumieć, ale lęka się, że nie zdąży… I za to, czego nigdy nie zrozumie. (…) Hej, słyszę znad stawu jakieś podniesione głosy. Wyjrzyj prędko, zobacz, co się tam dzieje.',
          '– Geralt (…) stoi z opuszczoną głową. A Yennefer strasznie wrzeszczy na niego. Wrzeszczy i wymachuje rękoma. Ojej… co to może znaczyć?',
          '– Dziecinnie proste – Jaskier znowu wpatrzył się w ciągnące po niebie obłoki. – Teraz ona przeprasza jego.',
          '',
          '- Andrzej Sapkowski, Czas pogardy',
        },
        {
          'A ja ci powiadam, że nie rozpoznałbyś strategii nawet wtedy, gdyby wyskoczyła z krzaków i kopnęła cię w dupę.',
          '',
          '- Andrzej Sapkowski, Chrzest ognia',
        },
        {
          '– Biedaków nigdy nie stać na nic, dlatego właśnie są biedakami.',
          '',
          '',
          '',
          '– Niesłychanie to logiczne. A odkrywcze, że aż dech zapiera.',
          '',
          '- Andrzej Sapkowski, Czas pogardy',
        },
        {
          'Zaiste, jak mawiał król Dezmod, zaglądnąwszy po skończonej potrzebie do nocnika: „Rozum nie jest w stanie tego ogarnąć”.',
          '',
          '- Andrzej Sapkowski, Pani Jeziora',
        },
        {
          '– Jak się czujesz? ',
          '– Świetnie. Pewnie blask słoneczny bije mi z dupy. Zajrzyj i sprawdź. Bo mnie trudno.',
          '',
          '- Andrzej Sapkowski, Narrenturm',
        },
        {
          '– Kici, kici koteczku – powiedział wiedźmin.',
          'Kot nieruchomiejąc spojrzał na niego złowrogo, położył uszy i zasyczał, obnażając kiełki.',
          '– Wiem – Geralt kiwnął głową. – Ja ciebie też nie lubię. Żartowałem tylko.',
          '',
          '- Andrzej Sapkowski, Miecz przeznaczenia',
        },
        {
          'Niewiedza (...) nie stanowi usprawiedliwienia dla nie przemyślanych działań. Gdy się nie wie, gdy ma się wątpliwości, dobrze jest zasięgnąć porady...',
          '',
          '- Andrzej Sapkowski, Chrzest ognia',
        },
        {
          'Lot numer siedem: dzwonek z trzonkiem, mosiężny, robota krasnoludzka, wiek znaleziska trudny do oszacowania, ale rzecz z pewnością starożytna. Na obwodzie napis krasnoludzkimi runami, głoszący: "No i czego ciulu dzwonisz". Cena wywoławcza...',
          '',
          '- Andrzej Sapkowski, Sezon burz',
        },
        {
          '– W każdej baśni jest ziarno prawdy – rzekł cicho wiedźmin. – Miłość i krew. obie mają potężną moc. Magowie i uczeni łamią sobie nad tym głowy od lat, ale nie doszli do niczego, poza ty, że...',
          '– Że co, Geralt?',
          '– Miłość musi być prawdziwa.',
          '',
          '- Andrzej Sapkowski, Ostatnie życzenie',
        },
        {
          'Popularne na dworze króla Vizimira powiedzonko głosiło, że jeśli Dijkstra twierdzi, że jest południe, a dookoła panują nieprzebite ciemności, należy zacząć niepokoić się o losy słońca.',
          '',
          '- Andrzej Sapkowski, Krew elfów',
        },
        {
          'Myślałem prędzej nierządem się parać i w domy publiczne inwestować. Wśród polityków się obracałem i licznych poznałem. I przekonałem się, że lepiej przestawać z kurwami, bo kurwy mają chociaż jakiś swój honor i jakieś zasady.',
          '',
          '- Andrzej Sapkowski, Sezon burz',
        },
      },
    }
  end

  return {
    { type = 'padding', val = 3 },
    {
      type = 'text',
      val = {
        '⠀⠀⣼⣀⠀⠀⠀⠀⢄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡠⠀⠀⠀⠀⣀⣧⠀⠀',
        '⠀⠀⠸⠻⣿⣶⣦⣤⣈⢻⣶⣮⢿⣿⣿⡿⣵⢶⡟⣁⣤⣴⣶⣿⠟⠇⠀⠀',
        '⠀⠀⠀⢪⢦⣙⠻⣿⣫⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣝⣿⠟⣋⡴⡕⠀⠀⠀',
        '⠀⠠⠤⣤⡩⡿⡇⣠⡙⢻⣯⣟⣿⣿⣿⣿⣻⣽⡟⢋⣄⢸⢿⢍⡤⠤⠄⠀',
        '⠀⠀⢀⣀⣤⣶⣽⡿⣿⡮⢭⣬⣽⣯⣽⣯⣥⡭⢵⣿⢿⣯⣶⣤⣀⡀⠀⠀',
        '⠒⠚⠛⠛⠛⠛⠛⠛⠓⠋⠛⢟⢿⣿⣿⡿⣻⠟⠙⠚⠛⠛⠛⠛⠛⠛⠓⠒',
        '⠀⠀⠀⠀⣀⣤⣴⣾⣿⠿⠃⠸⠷⠤⠤⠾⠇⠘⠿⣿⣷⣦⣤⣀⠀⠀⠀⠀',
        '⠀⠀⢀⣼⣿⣿⠿⠋⠁⠀⠀⢸⠧⠠⠄⠼⡇⠀⠀⠈⠙⠿⣿⣿⣧⡀⠀⠀',
        '⠀⣠⣾⠿⠋⠁⠀⣀⣴⡾⠁⢠⠀⠀⠀⠀⡄⠈⢷⣦⣀⠀⠈⠙⠿⣷⣄⠀',
        '⠴⠋⠁⠀⠀⠀⢀⣿⡟⠀⠀⢸⡇⣷⣾⢹⡇⠀⠀⢻⣿⡀⠀⠀⠀⠈⠙⠦',
        '⠀⠀⠀⠀⠀⠀⢸⠏⠀⠀⠀⠀⠁⠛⠛⠈⠀⠀⠀⠀⠹⡇⠀⠀⠀⠀⠀⠀',
        '⠀⠀⠀⠀⠀⠀⠋⠀⠀⠀⠀⠀⢰⣀⣀⡆⠀⠀⠀⠀⠀⠙⠀⠀⠀⠀⠀⠀',
        '⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣶⣶⡗⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀',
      },
      opts = { hl = 'AlphaLogo', position = 'center' },
    },
    { type = 'padding', val = 3 },
    {
      type = 'text',
      val = lazycache 'info',
      opts = { hl = 'AlphaInfo', position = 'center' },
    },
    { type = 'padding', val = 1 },
    {
      type = 'group',
      val = lazycache 'menu',
      opts = { spacing = 0 },
    },
    { type = 'padding', val = 1 },
    {
      type = 'group',
      val = lazycache 'mru',
      opts = { spacing = 0 },
    },
    { type = 'padding', val = 1 },
    {
      type = 'text',
      val = lazycache 'fortune',
      opts = { hl = 'AlphaQuote', position = 'center' },
    },
  }
end

return {
  'goolord/alpha-nvim',
  event = 'VimEnter',
  config = function()
    require('alpha').setup {
      layout = layout(),
      opts = {
        setup = function()
          vim.api.nvim_create_autocmd('User', {
            pattern = 'AlphaReady',
            desc = 'Disable status and tabline for alpha',
            callback = function()
              vim.go.laststatus = 0
            end,
          })
          vim.api.nvim_create_autocmd('BufUnload', {
            buffer = 0,
            desc = 'Enable status and tabline after alpha',
            callback = function()
              vim.go.laststatus = 3
            end,
          })
        end,
        margin = 5,
      },
    }
  end,
}
