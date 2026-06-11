# Polityka prywatności Nurtly - wersja robocza

**Data wejścia w życie:** [DATE_TBD]

**Adres polityki prywatności:** [PRIVACY_POLICY_URL_TBD]

**Kontakt:** [CONTACT_EMAIL_TBD]

Niniejszy dokument jest wersją roboczą przeznaczoną do przygotowania publikacji polityki prywatności aplikacji Nurtly. Przed opublikowaniem treść musi zostać sprawdzona pod kątem zgodności prawnej i zgodności z rzeczywistą konfiguracją produkcyjną aplikacji.

## 1. Kim jesteśmy

Nurtly to aplikacja dla rodziców i opiekunów, nie dla dzieci. Pomaga w spokojnym korzystaniu z:

- pomysłów na zabawy i aktywności,
- kojących dźwięków,
- lokalnego dziennika codziennej opieki.

## 2. Jakie dane przetwarzamy

W zależności od używanych funkcji aplikacja może przetwarzać:

- dane wpisywane przez użytkownika w dzienniku, w tym notatki i zdarzenia opieki,
- dane dotyczące subskrypcji i statusu Premium,
- dane techniczne i informacje o urządzeniu, jeśli są potrzebne do reklam, płatności, analityki lub diagnostyki w finalnej konfiguracji produkcyjnej.

W MVP nie jest wymagane imię dziecka ani dokładna data urodzenia dziecka.

## 3. Dziennik

Dziennik w obecnej implementacji jest lokalny.

- wpisy dziennika są zapisywane na urządzeniu,
- notatki dziennika nie są wysyłane do backendu ani chmury w obecnej implementacji,
- dane dziennika służą do odczytu historii opieki na tym urządzeniu,
- treść notatek dziennika nie jest przeznaczona do reklam ani profilowania dziecka.

Użytkownik może usunąć aplikację, aby usunąć lokalne dane, z zastrzeżeniem, że kopie zapasowe systemu lub usług platformy mogą nadal zawierać dane zgodnie z ustawieniami urządzenia i konta.

## 4. Płatności i subskrypcje

Aplikacja może używać Google Play Billing do obsługi subskrypcji Premium.

Możemy przetwarzać dane o zakupie, aktywacji, odnowieniu, anulowaniu, wygaśnięciu lub przywróceniu subskrypcji, aby utrzymać poprawny stan uprawnień Premium.

## 5. Reklamy

Aplikacja może wyświetlać reklamy użytkownikom darmowym.

Premium nie powinien widzieć reklam.

W MVP reklamy mają pozostać pasywne i banerowe wyłącznie w obszarach przeglądania oraz nie mogą przerywać tworzenia lub edycji wpisów w dzienniku, aktywnego odtwarzania dźwięku, ekranów Prywatność lub Ustawienia ani momentów uruchamiania aplikacji.

W finalnej konfiguracji produkcyjnej mogą być przetwarzane dane urządzenia lub aplikacji potrzebne do działania reklam, zgodnie z konfiguracją Google i ustawieniami urządzenia.

## 6. Cel przetwarzania

Dane wykorzystujemy, aby:

- zapewnić działanie aplikacji,
- przechowywać lokalny dziennik opieki,
- obsługiwać subskrypcje Premium,
- wyświetlać reklamy użytkownikom darmowym,
- utrzymywać podstawową diagnostykę i niezawodność aplikacji, jeśli taka funkcja jest włączona w finalnej wersji,
- mierzyć jakość aplikacji, użycie modułów, retencję, reklamy i błędy, jeśli analityka zostanie włączona w finalnej wersji.

## 7. Czego nie robimy

W obecnej implementacji aplikacja nie jest przeznaczona do:

- udzielania porad medycznych,
- diagnozowania,
- coachingu snu,
- oceniania rozwoju dziecka,
- wysyłania dziennika do chmury,
- analizowania treści dziennika do reklam lub profilowania dziecka.

## 8. Odbiorcy danych

W zależności od finalnej konfiguracji produkcyjnej dane mogą być przetwarzane przez:

- Google Play Billing,
- usługi reklamowe,
- usługi techniczne potrzebne do działania aplikacji.

Dokładny zakres musi odpowiadać rzeczywistemu zachowaniu opublikowanej wersji aplikacji i ustawieniom Google Play Console.

## 9. Bezpieczeństwo

Stosujemy zabezpieczenia techniczne i organizacyjne odpowiednie do skali aplikacji MVP. Szczegóły finalnej konfiguracji bezpieczeństwa muszą odpowiadać wdrożeniu produkcyjnemu.

## 10. Zmiany w polityce

Możemy aktualizować tę politykę wraz z rozwojem aplikacji, zmianami funkcji lub wymaganiami prawnymi.

## 11. Kontakt

W sprawach dotyczących prywatności skontaktuj się z nami pod adresem: [CONTACT_EMAIL_TBD]

## 12. Ważne uwagi

- Ten dokument jest szkicem i nie stanowi porady prawnej.
- Finalna treść musi zostać zweryfikowana przed publikacją.
- Odpowiedzi Data Safety muszą być zgodne z finalnym zachowaniem produkcyjnym aplikacji.
- Finalne zachowanie reklam i subskrypcji musi być potwierdzone przed publikacją.
