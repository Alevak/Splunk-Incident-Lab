🛡️ Use Case Descriptions

Suspicious PowerShell Encoded Command
Файл логів: `sysmon_powershell_base64.json`

Цей юз-кейс виявляє використання PowerShell з параметром `-enc`, який означає запуск закодованої у Base64 команди. Це типовий прийом для приховування шкідливого скрипту, який часто використовується при атаках з використанням PowerShell.

SPL Запит:
```spl
index=main sourcetype=sysmon Image=*powershell.exe* CommandLine="*-enc*"
```

Виявлення використання Mimikatz
Файл логів**: `windows_mimikatz.json`

Цей юз-кейс орієнтований на виявлення запуску інструменту Mimikatz, який використовується для крадіжки облікових даних у Windows-системах. У логах можна побачити згадки про mimikatz або специфічні функції, що викликаються цим інструментом.

SPL Запит:
```spl
index=main sourcetype=sysmon CommandLine=*mimikatz*
```

Brute-force атака на облікові записи
Файл логів: `sysmon_bruteforce.json`

Цей юз-кейс імітує спробу брутфорсу логінів у Windows. У логах видно послідовні невдалі логіни з коротким інтервалом між ними, що є характерною ознакою brute-force атак.

SPL Запит:
```spl
index=main sourcetype=sysmon EventCode=4625 | stats count by Account_Name, IpAddress
```

Виконання файлу з каталогу /tmp
Файл логів**: `linux_tmp_exec.json`

Виконання бінарників або скриптів із каталогу `/tmp` в Linux є типовим шаблоном для зловмисних дій, оскільки цей каталог часто використовується як тимчасове місце зберігання шкідливих компонентів.

SPL Запит:
```spl
index=main sourcetype=linux_logs CommandLine="/tmp/*"
```

Підозріле використання sudo без пароля
Файл логів**: `linux_sudo_nopasswd.json`

Якщо в Linux-конфігурації вказано `NOPASSWD` у sudoers-файлі, це дозволяє запускати команди з правами суперкористувача без пароля. Це може бути легальним, але часто використовується при ескалації привілеїв.

SPL Запит:
```spl
index=main sourcetype=linux_logs CommandLine=*sudo* AND CommandLine=*NOPASSWD*
```

DNS-запити до динамічного DNS-сервісу (duckdns)
Файл логів**: `network_dns_duckdns.json`

Виявлення DNS-запитів до сервісів типу `duckdns.org` допомагає ідентифікувати потенційне використання динамічних C2 (Command & Control) серверів. Такі сервіси часто використовуються шкідливим ПЗ для обходу фільтрації або забезпечення стійкого з’єднання.

SPL Запит:
```spl
index=main sourcetype=dns_logs query=*duckdns.org*
```
