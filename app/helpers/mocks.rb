# frozen_string_literal: true

module Mocks
  def self.date_from_now(months, days = 0)
    Date.today.next_month(months).next_day(days)
  end
  def self.permissions_mock(user_id)
    case user_id
    when '1' # Test Organizer
      {
        'can_attend_competitions' => {
          'scope' => '*',
        },
        'can_organize_competitions' => {
          'scope' => %w[CubingZANationalChampionship2023],
        },
        'can_administer_competitions' => {
          'scope' => %w[CubingZANationalChampionship2023],
        },
      }
    when '2' # Test Multi-Comp Organizer
      {
        'can_attend_competitions' => {
          'scope' => '*',
        },
        'can_organize_competitions' => {
          'scope' => %w[LazarilloOpen2023 CubingZANationalChampionship2023],
        },
        'can_administer_competitions' => {
          'scope' => %w[LazarilloOpen2023 CubingZANationalChampionship2023],
        },
      }
    when '15073', '15074' # Test Admin
      {
        'can_attend_competitions' => {
          'scope' => '*',
        },
        'can_organize_competitions' => {
          'scope' => '*',
        },
        'can_administer_competitions' => {
          'scope' => '*',
        },
      }
    when '209943' # Test banned User
      {
        'can_attend_competitions' => {
          'scope' => [],
          'reasons' => ErrorCodes::USER_IS_BANNED,
        },
        'can_organize_competitions' => {
          'scope' => [],
        },
        'can_administer_competitions' => {
          'scope' => [],
        },
      }
    when '999999' # Test incomplete User
      {
        'can_attend_competitions' => {
          'scope' => [],
          'reasons' => ErrorCodes::USER_PROFILE_INCOMPLETE,
        },
        'can_organize_competitions' => {
          'scope' => [],
        },
        'can_administer_competitions' => {
          'scope' => [],
        },
      }
    else # Default value for test competitors
      {
        'can_attend_competitions' => {
          'scope' => '*',
        },
        'can_organize_competitions' => {
          'scope' => [],
        },
        'can_administer_competitions' => {
          'scope' => [],
        },
      }
    end
  end

  def self.mock_competition(competition_id)
    case competition_id
    when "KoelnerKubing2023"
      {
        'id': 'KoelnerKubing2023',
        'name': 'Kölner Kubing 2023',
        'information':
          '**German**\r\nWillkommen in Köln! Endlich ist es wieder soweit - eine Speedcubing-Competition in unserer Stadt! Wir freuen uns auf dieses Wochenende mit vielen interessanten Events.\r\n\r\nAm 11. November (Samstag) ist in Köln der Beginn des Karnevals. Rechnet mit Verspätungen des Nahverkehrs!\r\n\r\n\r\n**English**\r\nWelcome to Cologne! The time has finally come again - a Speedcubing-Competition in our city! We are looking forward to this weekend with many interesting events.\r\n\r\nOn November 11th (Saturday), Cologne Carnival is set to start. Expect delays in public transportation!',
        'venue': 'Pfarrheim St. Engelbert',
        'contact':
          '[Kölner Kubing 2023 Orgateam](mailto:koelnerkubing@googlegroups.com)',
        'registration_open': self.date_from_now(-1, -1),
        'registration_close': self.date_from_now(2),
        'use_wca_registration': true,
        'announced_at': '2023-08-22T17:10:32.000Z',
        'base_entry_fee_lowest_denomination': 1600,
        'currency_code': 'EUR',
        'start_date': self.date_from_now(2),
        'end_date': self.date_from_now(2, 1),
        'enable_donations': true,
        'competitor_limit': 100,
        'extra_registration_requirements':
          "### Deutsch:\r\n\r\n**1. Erstelle einen WCA-Account**\r\n(Dieser Schritt gilt NUR für Newcomer und Teilnehmer ohne WCA-Account): Erstelle [hier](https://www.worldcubeassociation.org/users/sign_up) einen WCA-Account.\r\n**2. Zahle die Anmeldegebühr**\r\nZahle die Anmeldegebühr in Höhe von 16 Euro via PayPal [*über diesen Link*](https://www.paypal.com/paypalme/FrederikHutfless/16eur) (https://www.paypal.com/paypalme/FrederikHutfless/16eur). \r\n**3. Fülle das Anmeldeformular aus**\r\nFülle das Anmeldeformular aus und schicke es ab: [klicke hier und scrolle ganz nach unten ans Ende der Seite](https://www.worldcubeassociation.org/competitions/KoelnerKubing2023/register).\r\n\r\n**Wichtig:** \r\n* Bitte aktiviere **nicht** den optionalen Käuferschutz, da hierfür eine Gebühr vom gezahlten Eintrittspreis abgezogen wird. \r\n* Falls der Name bei der Zahlung und der Name im Anmeldeformular nicht identisch sind, gib bitte den Namen des Teilnehmers im Anmeldeformular im letzten Schritt der Zahlungsprozedur an oder kontaktiere uns. *Eine Zahlung gilt erst dann als geleistet, wenn wir diese eindeutig zuordnen können.* \r\n* **Ohne (eindeutig zugeordnete) Zahlung gilt die Anmeldung als nicht vollständig und wird nicht bestätigt.**\r\n\r\nWenn das Teilnehmerlimit bereits erreicht wurde, erhältst du nach Anmeldung und Zahlung einen Platz auf der Warteliste. Danach erhältst du eine E-Mail, sobald ein Platz für dich frei werden sollte. Falls du keinen freien Teilnehmerplatz mehr erlangen solltest, wird die Anmeldegebühr selbstverständlich erstattet.\r\n\r\nSolltest du nicht mehr teilnehmen können und deine Anmeldung daher stornieren wollen, bitten wir dich darum, uns zu informieren. Dadurch kann ein Teilnehmer auf der Warteliste nachrücken! Du erhältst eine Erstattung der gesamten Anmeldegebühr (100%), wenn du deine Anmeldung vor dem 03. November 2023, 23:59 MESZ stornierst.\r\n\r\nWenn absehbar ist, dass die Warteliste bereits so lang ist, dass weitere Neuanmeldungen nicht mehr angenommen werden, behalten wir uns vor, die Anmeldung früher als angekündigt zu schließen.\r\n\r\nWir haben [häufig gestellte Fragen und Antworten hier](https://www.worldcubeassociation.org/competitions/KoelnerKubing2023#31967-faq) zusammengestellt.\r\n\r\n#### Für Gäste:\r\nJeder Gast zahlt 3€ (Euro) Eintitt vor Ort\r\n### English:\r\n\r\n**1. Create an WCA account**\r\n(This step is ONLY for newcomers and competitors without a WCA account:) Create a WCA-account [here](https://www.worldcubeassociation.org/users/sign_up).\r\n**2. Pay the registration fee**\r\nPay the registration fee of 16 Euro by following [*this link*](https://www.paypal.com/paypalme/FrederikHutfless/16eur) (https://www.paypal.com/paypalme/FrederikHutfless/16eur) and proceed with the payment via Paypal.\r\n**3. Fill in the registration form**\r\nFill and submit the registration form here: [click here and scroll all the way down to the bottom of the page](https://www.worldcubeassociation.org/competitions/KoelnerKubing2023/register).\r\n\r\n**Important:**\r\n* Please do **not** activate the optional buyer protection as this will be deducted as a fee from the amount you pay. \r\n* If the name of the payment and the name in the registration form are not identical, please enter the name of the competitor from on the registration form in the final step of the payment procedure or contact us. *A payment is only considered to be made once we can clearly match it.*\r\n* **The registration is not considered complete and will not be confirmed until a (clearly matched) payment is made.**\r\n\r\nIf you have registered and paid but the competitor limit has been reached, you will receive a spot on the waiting list. You will be notified via email once a spot for you becomes available. If you do not move up from the waiting list until registration closes, you will get a full refund.\r\n\r\nIf you find that you can not attend the competition anymore, please inform us via e-mail. That way, another competitor can fill your spot! You will receive a full refund (100%) of the entrance fee if you cancel your registration before November 03, 2023, 11:59 PM GMT+2.\r\n\r\nOnce the waiting list is long enough for us to anticipate that new registrations will likely not move up to the competitor's list, we may close the registration earlier than announced. \r\n\r\nWe compiled a set of [frequently asked questions and answers here](https://www.worldcubeassociation.org/competitions/KoelnerKubing2023#31967-faq).\r\n\r\n#### For guests:\r\nEach guest pays 3€ (Euro) entrance fee",
        'on_the_spot_registration': false,
        'on_the_spot_entry_fee_lowest_denomination': nil,
        'refund_policy_percent': 100,
        'refund_policy_limit_date': self.date_from_now(2),
        'guests_entry_fee_lowest_denomination': 300,
        'qualification_results': false,
        'external_registration_page': '',
        'event_restrictions': false,
        'cancelled_at': nil,
        'waiting_list_deadline_date': self.date_from_now(2, -1),
        'event_change_deadline_date': self.date_from_now(2, -1),
        'guest_entry_status': 'free',
        'allow_registration_edits': true,
        'allow_registration_self_delete_after_acceptance': false,
        'allow_registration_without_qualification': false,
        'guests_per_registration_limit': nil,
        'force_comment_in_registration': false,
        'url': 'https://www.worldcubeassociation.org/competitions/KoelnerKubing2023',
        'website':
          'https://www.worldcubeassociation.org/competitions/KoelnerKubing2023',
        'short_name': 'Kölner Kubing 2023',
        'city': 'Köln',
        'venue_address': 'Pfarrer-Moll-Str. 54, 51105 Cologne, Germany',
        'venue_details': 'Obergeschoss // upstairs',
        'latitude_degrees': 50.929833,
        'longitude_degrees': 6.995431,
        'country_iso2': 'DE',
        'event_ids': %w[333 222 444 555 666 777 333fm 333oh clock pyram skewb],
        'registration_opened?': true,
        'main_event_id': '333',
        'number_of_bookmarks': 66,
        'using_stripe_payments?': nil,
        'uses_qualification?': false,
        'uses_cutoff?': true,
        'delegates': [
          {
            id: 2,
            created_at: '2012-07-25T05:42:29.000Z',
            updated_at: '2023-10-25T17:31:40.000Z',
            name: 'Sébastien Auroux',
            delegate_status: 'delegate',
            wca_id: '2008AURO01',
            gender: 'm',
            country_iso2: 'DE',
            url: 'https://www.worldcubeassociation.org/persons/2008AURO01',
            country: {
              id: 'Germany',
              name: 'Germany',
              continentId: '_Europe',
              iso2: 'DE',
            },
            email: 'sauroux@worldcubeassociation.org',
            location: 'Germany',
            senior_delegate_id: 454,
            class: 'user',
            teams: [
              {
                id: 190,
                friendly_id: 'wrt',
                leader: true,
                name: 'Sébastien Auroux',
                senior_member: false,
                wca_id: '2008AURO01',
                avatar: {
                  url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2008AURO01/1630621356.jpg',
                  thumb: {
                    url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2008AURO01/1630621356_thumb.jpg',
                  },
                },
              },
            ],
            avatar: {
              url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2008AURO01/1630621356.jpg',
              pending_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              thumb_url:
                'https://avatars.worldcubeassociation.org/uploads/user/avatar/2008AURO01/1630621356_thumb.jpg',
              is_default: false,
            },
          },
          {
            id: 870,
            created_at: '2015-06-30T10:47:15.000Z',
            updated_at: '2023-10-15T16:01:39.000Z',
            name: 'Laura Ohrndorf',
            delegate_status: 'delegate',
            wca_id: '2009OHRN01',
            gender: 'f',
            country_iso2: 'DE',
            url: 'https://www.worldcubeassociation.org/persons/2009OHRN01',
            country: {
              id: 'Germany',
              name: 'Germany',
              continentId: '_Europe',
              iso2: 'DE',
            },
            email: 'lohrndorf@worldcubeassociation.org',
            location: 'Germany',
            senior_delegate_id: 454,
            class: 'user',
            teams: [],
            avatar: {
              url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2009OHRN01/1501490937.png',
              pending_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              thumb_url:
                'https://avatars.worldcubeassociation.org/uploads/user/avatar/2009OHRN01/1501490937_thumb.png',
              is_default: false,
            },
          },
          {
            id: 7139,
            created_at: '2015-12-20T17:41:42.000Z',
            updated_at: '2023-10-30T20:30:40.000Z',
            name: 'Annika Stein',
            delegate_status: 'candidate_delegate',
            wca_id: '2014STEI03',
            gender: 'f',
            country_iso2: 'DE',
            url: 'https://www.worldcubeassociation.org/persons/2014STEI03',
            country: {
              id: 'Germany',
              name: 'Germany',
              continentId: '_Europe',
              iso2: 'DE',
            },
            email: 'astein@worldcubeassociation.org',
            location: 'Germany',
            senior_delegate_id: 454,
            class: 'user',
            teams: [
              {
                id: 510,
                friendly_id: 'wac',
                leader: false,
                name: 'Annika Stein',
                senior_member: false,
                wca_id: '2014STEI03',
                avatar: {
                  url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2014STEI03/1527407820.jpg',
                  thumb: {
                    url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2014STEI03/1527407820_thumb.jpg',
                  },
                },
              },
            ],
            avatar: {
              url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2014STEI03/1527407820.jpg',
              pending_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              thumb_url:
                'https://avatars.worldcubeassociation.org/uploads/user/avatar/2014STEI03/1527407820_thumb.jpg',
              is_default: false,
            },
          },
        ],
        'organizers': [
          {
            id: 80119,
            created_at: '2017-11-04T21:20:56.000Z',
            updated_at: '2023-10-30T09:30:27.000Z',
            name: 'Dunhui Xiao (肖敦慧)',
            delegate_status: nil,
            wca_id: '2018XIAO03',
            gender: 'm',
            country_iso2: 'DE',
            url: 'https://www.worldcubeassociation.org/persons/2018XIAO03',
            country: {
              id: 'Germany',
              name: 'Germany',
              continentId: '_Europe',
              iso2: 'DE',
            },
            class: 'user',
            teams: [],
            avatar: {
              url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2018XIAO03/1681755209.jpg',
              pending_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              thumb_url:
                'https://avatars.worldcubeassociation.org/uploads/user/avatar/2018XIAO03/1681755209_thumb.jpg',
              is_default: false,
            },
          },
          {
            id: 121445,
            created_at: '2018-08-27T16:09:20.000Z',
            updated_at: '2023-10-30T07:36:32.000Z',
            name: 'Christian Beemelmann',
            delegate_status: nil,
            wca_id: '2017BEEM02',
            gender: 'm',
            country_iso2: 'DE',
            url: 'https://www.worldcubeassociation.org/persons/2017BEEM02',
            country: {
              id: 'Germany',
              name: 'Germany',
              continentId: '_Europe',
              iso2: 'DE',
            },
            class: 'user',
            teams: [],
            avatar: {
              url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2017BEEM02/1682348631.jpg',
              pending_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              thumb_url:
                'https://avatars.worldcubeassociation.org/uploads/user/avatar/2017BEEM02/1682348631_thumb.jpg',
              is_default: false,
            },
          },
          {
            id: 121461,
            created_at: '2018-08-27T17:59:29.000Z',
            updated_at: '2023-09-21T22:00:59.000Z',
            name: 'Frederik Hutfleß',
            delegate_status: nil,
            wca_id: '2014HUTF01',
            gender: 'm',
            country_iso2: 'DE',
            url: 'https://www.worldcubeassociation.org/persons/2014HUTF01',
            country: {
              id: 'Germany',
              name: 'Germany',
              continentId: '_Europe',
              iso2: 'DE',
            },
            class: 'user',
            teams: [],
            avatar: {
              url: 'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              pending_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              thumb_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              is_default: true,
            },
          },
          {
            id: 263512,
            created_at: '2022-04-01T22:47:05.000Z',
            updated_at: '2023-10-30T23:23:42.000Z',
            name: 'Lion Jäschke',
            delegate_status: nil,
            wca_id: '2023JASC01',
            gender: 'm',
            country_iso2: 'DE',
            url: 'https://www.worldcubeassociation.org/persons/2023JASC01',
            country: {
              id: 'Germany',
              name: 'Germany',
              continentId: '_Europe',
              iso2: 'DE',
            },
            class: 'user',
            teams: [],
            avatar: {
              url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2023JASC01/1695512242.jpg',
              pending_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              thumb_url:
                'https://avatars.worldcubeassociation.org/uploads/user/avatar/2023JASC01/1695512242_thumb.jpg',
              is_default: false,
            },
          },
        ],
        'tabs': [
          {
            id: 31963,
            competition_id: 'KoelnerKubing2023',
            name: 'Neulinge \u0026 Ergebnisse / Newcomers \u0026 Results',
            content:
              "# Deutsch\r\n## Informationen für Neulinge\r\nFalls dies dein erstes WCA Turnier sein sollte, beachte bitte die folgenden Punkte:\r\n\r\n- Alle Neulinge sind dazu verpflichtet ein **Ausweisdokument** an der Anmeldung vor zu zeigen (Regulation [2e](https://www.worldcubeassociation.org/regulations/#2e))). Aus dem Dokument müssen Name, Nationalität und Geburtsdatum hervorgehen.\r\n- Alle Neulinge sind eindringlich gebeten, am **Tutorial** (siehe Zeitplan) teilzunehmen.\r\n- Jeder Teilnehmer sollte bereits vor der Meisterschaft mindestens einmal die **[offiziellen Regeln der WCA](https://www.worldcubeassociation.org/regulations/translations/german/)** gelesen haben. Zusätzlich empfehlen wir euch einen Blick in das [WCA Competition Tutorial](https://www.worldcubeassociation.org/files/WCA_Competition_Tutorial.pdf) bzw. unsere deutschsprachige [Teilnehmer-Anleitung](https://www.germancubeassociation.de/anleitungen/). Dort findet ihr wichtige Infos zum Ablaub und zur Teilnahme am Wettbewerb. Weiterhin bietet zum Beispiel auch [dieses Video-Tutorial](https://www.youtube.com/watch?v=dPL3eV-A0ww) einen guten unterstützenden Einblick.\r\n- Keine Angst: während des Turniers besteht die Möglichkeit, sich mit dem offiziellen Equipment (Stackmat-Timer) vertraut zu machen und Fragen zu stellen.\r\n\r\n\r\nBei Unklarheiten oder wichtigen Fragen vor dem Turnier kannst du dich gerne [an das Organisationsteam wenden](mailto:KoelnerKubing@googlegroups.com).\r\n\r\nLive Ergebnisse sind über [WCA Live](https://live.worldcubeassociation.org/) verfügbar. Nach dem Wettkampf werden alle Ergebnisse in die Datenbank der WCA hochgeladen, und auf dieser Seite einzusehen sein.\r\n\r\n___\r\n\r\n# English\r\n## Newcomer information\r\nIf this is your first WCA competition, please pay attention to the following:\r\n\r\n- According to Regulation [2e)](https://www.worldcubeassociation.org/regulations/#2e), all newcomers are required to bring some form of **identification document** that shows name, citizenship and date of birth.\r\n- All newcomers are urgently asked to attend the **Tutorial** (see schedule).\r\n- Every competitor should have read the **[official WCA regulations](https://www.worldcubeassociation.org/regulations)** at least once before attending the competition! A more condensed version of the important regulations can be found at the [WCA Competition Tutorial](https://www.worldcubeassociation.org/files/WCA_Competition_Tutorial.pdf). We also recommend [this video guide](https://www.youtube.com/watch?v=dPL3eV-A0ww) for a more visual impression.\r\n- Don't be afraid: there will also be time to test the equipment (for example the official timing device, the Stackmat timer) and discuss the rules if you have questions at the competition.\r\n\r\nFeel free to [contact the organizer](mailto:KoelnerKubing@googlegroups.com) if you have any uncertainties.\r\n\r\nLive results are available via [WCA Live](https://live.worldcubeassociation.org/). All results will be uploaded to the WCA database after the competition, and will be available right here.",
            display_order: 1,
          },
          {
            id: 31964,
            competition_id: 'KoelnerKubing2023',
            name: 'Verpflegung / Food',
            content:
              '# Deutsch\r\n\r\nEs befinden sich in der Umgebung der Venue zahlreiche Bäckereien und Restaurants, außerdem direkt fußläufig ein Netto (ca. 200 m).\r\nAußerdem werden wir kostenlose Getränke für Teilnehmer und Gäste zur Verfügung stellen.\r\n\r\nIn der Nähe vom Bahnhof/Venue gibt es ein Einkaufszentrum: Köln Arcaden. \r\nIm Untergeschoss findet man unter anderem Burger King, Nordsee, asiatische Restaurants und vieles mehr.\r\n\r\nDer Fußweg von der Venue zum Einkaufszentrum beträgt ungefähr 10 Minuten.\r\nDer Fußweg vom Bahnhof Trimbornstraße zum Einkaufszentrum beträgt ungefähr 5 Minuten.\r\n**Adresse: Kalker Hauptstraße 55, 51103 Köln**\r\n___\r\n\r\n# English\r\n\r\nThere are numerous bakeries and restaurants in the immediate vicinity of the venue, as well as a Netto (supermarket) that can be reached on foot (about 200 m).\r\nAdditionally, we will provide participants and guests with free drinks.\r\n\r\nClose to the train station / venue, there is a shopping centre: Köln Arcaden.\r\nOn the lower floor, you can find, among others, Burger King, Nordsee (seafood chain restaurant), Asian restaurants, and more.\r\n\r\nThe shopping centre can be reached on foot in about 10 minutes.\r\nFrom train station Trimbornstraße it can be reached in about 5 minutes.\r\n**Adress: Kalker Hauptstraße 55, 51003 Cologne**',
            display_order: 2,
          },
          {
            id: 31965,
            competition_id: 'KoelnerKubing2023',
            name: 'Anreise \u0026 Unterkunft / Travel \u0026 Accomodation',
            content:
              "# Deutsch\r\n### Mit dem Auto\r\n\r\nÜber die A4 auf die A559 (Kreuz Gremberg) Richtung Deutz, Ausfahrt Kalk/Poll nehmen.\r\n\r\n\r\n### Mit öffentlichen Verkehrsmitteln\r\n\r\nVom Hauptbahnhof bzw. von Köln Messe/Deutz mit der S12, S13, S19 oder RB25 zur Haltestelle Trimbornstraße. Von dort sind es ca. 10 Minuten Fußweg. \r\nAlternativ fährt eine Straßenbahn ab Bf Deutz/Messe (U) (Gleis 2) die Linie 1 nach Kalk Post (Fußweg zur Venue ~ 900 m).\r\nVon Bf Deutz/LANXESS arena fährt die Buslinie 153 (Endhaltestelle: Esserstr., Köln Humboldt-Gremberg; Fußweg zur Venue: ~140 m). \r\n\r\n### Unterkunft\r\n\r\nEs gibt zahlreiche Unterkünfte in der Umgebung der Venue. Hier ist eine Auswahl:\r\n\r\nHotel Ars Vivendi\r\nGästehaus Messetip\r\nB\u0026B Hotel Köln-Messe\r\nDJH Köln-Deutz\r\nBest Western Hotel Köln \r\n\r\n**HINWEIS**: Durchsucht Booking.com / Airbnb nach Unterkünfte (Vorteilhaft auf der **rechten** Rheinseite). Wegen des Karnevals sind Unterkünfte früh ausgebucht.\r\n\r\nFalls Ihr in Köln nichts findet, schaut in Leverkusen/Bonn/Bergisch Gladbach nach. Von dort könnt ihr die Venue über den Bahnhof Messe/Deutz erreichen, ohne die Innenstadt durchqueren zu müssen.\r\n\r\nDer Karneval findet in der Gegend vom Kölner Dom bis Köln Neumarkt (linke Rheinseite) statt. \r\n\r\n___\r\n\r\n# English\r\n### By car\r\n\r\nVia the A4 onto the A559 (motorway junction / Kreuz Gremberg) in the direction of Deutz, then take the exit Kalk/Poll.\r\nAlternatively, there is a tram from Bf Deutz/Messe (U) (platform 2), line 1 to Kalk Post (walking distance to the venue ~ 900 m).\r\nFrom Bf Deutz/LANXESS arena bus line 153 (final stop: Esserstr., Köln Humboldt-Gremberg; walking distance to the venue: ~140 m). \r\n\r\n\r\n### By public transport\r\n\r\nFrom Köln / Cologne Main Station or Köln Messe/Deutz via S12, S13, S19 or RB25 to station Trimbornstraße. From there about 10 minutes on foot. \r\n\r\n\r\n### Accomodation\r\n\r\nThere are numerous accomodations close to the venue. Here is a selection:\r\n\r\nHotel Ars Vivendi\r\nGästehaus Messetip\r\nB\u0026B Hotel Köln-Messe\r\nDJH Köln-Deutz\r\nBest Western Hotel Köln \r\n\r\n**NOTE**: Search Booking.com / Airbnb for accommodations (Preferably on the **right** side of the Rhine). Due to the Carnival, accomodation will be booked out early.\r\n\r\nIf you don't find accomodation in Cologne City, you can look in Leverkusen/Bonn/Bergisch Gladbach. From there, you can access the venue via Messe/Deutz station, without the need to traverse the inner city.\r\n\r\nCarnival takes place in the area from Cologne Cathedral to Cologne Neumarkt (left side of the Rhine). ",
            display_order: 3,
          },
          {
            id: 31966,
            competition_id: 'KoelnerKubing2023',
            name: 'Warteliste / Waiting list',
            content:
              '### Deutsch\r\nWenn das Teilnehmerlimit erreicht ist, wenden wir folgendes Verfahren an:\r\n\r\nDu kannst auf die Warteliste gelangen, wenn du die folgenden notwendigen Schritte ausführst:\r\n1. Anmeldegebühr zahlen\r\n2. Auf der Website registrieren\r\nBeides ist notwendig um im Falle der Abmeldung eines anderen Teilnehmers den Platz erhalten zu können. Falls zutreffend, geschieht das Nachrücken in der Reihenfolge der vollständigen Anmeldung (= Schritt 1 und 2 erfolgreich durchgeführt). Es ensteht Dir kein Nachteil, solltest Du keinen Platz im Nachrückverfahren erhalten, denn in diesem Fall erhältst Du die Anmeldegebühr selbstverständlich zurück. Wenn die Warteliste zu lang werden sollte, kann die Anmeldung vorzeitig geschlossen werden.\r\n\r\n___\r\n\r\n### English\r\nIf the competitor limit has been reached, we proceed as follows:\r\n\r\nYou may be placed on the waiting list by completing the following relevant steps:\r\n1. Pay the registration fee\r\n2. Register via the website\r\nBoth are mandatory to be considered once someone cancels their registration. Moving up from the waiting list will be done in the order of complete registration (= step 1 and 2 completed successfully). If you can not obtain a spot through the waiting list procedure, you will of course get a full refund of the registration fee. Should the waiting list become too long, we may close the registration early.\r\n\r\n\r\n### Names and positions on the waiting list\r\n(In order of complete registration):\r\n\r\n13. Tim Selbach\r\n14. Baoxuan Guo\r\n15. Moritz Alexander Stolpe\r\n16. Elliot Sherrow\r\n17. Janek Gehrlein\r\n18. Merlin Ehl\r\n19. Mert Tinaz\r\n20. Arne Ritterskamp \r\n21. Nazar Pryshchepa\r\n22. Dmytro Poplavskyi',
            display_order: 4,
          },
          {
            id: 32054,
            competition_id: 'KoelnerKubing2023',
            name: 'Auszeichnungen / Awards',
            content:
              '**German**\r\nEs besteht die Möglichkeit Pokale zu gewinnen, für jedes Event gibt es für den Ersten Platz einen Pokal!\r\n\r\n3x3x3 Platz 1: Pokal\r\n3x3x3 Platz 2: Medaille \r\n3x3x3 Platz 3: Medaille \r\n\r\nFür jedes andere Event auf Platz 1: Pokal\r\n\r\n___\r\n\r\n**English**\r\nThere is a chance to win trophies, for each event there is a trophy for first place!\r\n\r\n3x3x3 1st place: Trophy\r\n3x3x3 2nd place: medal \r\n3x3x3 3rd place: medal\r\n\r\nFor every other event ranked 1st: Trophy',
            display_order: 5,
          },
          {
            id: 31967,
            competition_id: 'KoelnerKubing2023',
            name: 'FAQ',
            content:
              '*(English version below)*\r\n\r\n### German\r\n\r\n* *Wie kann ich mich registrieren?*\r\nZunächst solltest du einen **WCA Account** einrichten, falls du noch keinen besitzt (der WCA Account ist nicht dasselbe wie die *WCA ID*, welche du erst nach deinem ersten Wettbewerb für dein persönliches Profil erhältst). Melde dich dann mit diesem Account auf der WCA Website an, navigiere zu diesem Wettbewerb und klicke auf "Anmelden". Alle weiteren Schritte, auch zur Bezahlung, sind dort erläutert. Die wichtigsten Punkte wiederholen wir gerne hier erneut: erst, wenn du dich angemeldet und die Teilnahmegebühr gezahlt hast, kann deine Anmeldung weiter berücksichtigt werden. Je nachdem, wann du dich anmeldest, gelangst du dann auf die Teilnehmerliste, oder, wenn das Teilnehmerlimit bereits erreicht wurde, auf die Warteliste. Ein Platz auf der Warteliste begründet keinen Anspruch auf Teilnahme am Wettbewerb, und erst, wenn sich jemand anderes abmeldet, können Personen von der Warteliste auf die Teilnehmerliste nachrücken. Welcher Fall für dich zutrifft, erfährst du a) über die Website b) persönliche E-Mails. Stelle daher sicher, dass die angegebene Mailadresse aktuell ist, oder ändere sie bei Bedarf.\r\n\r\n* *Ich habe kein PayPal, wie kann ich mich trotzdem anmelden und die Zahlung vornehmen?*\r\nKontaktiere uns über das Kontaktformular, sodass wir dir alternative Zahlungsmethoden zukommen lassen können.\r\n\r\n* *Gibt es ein Mindestalter? Gibt es verschiedene Alterskategorien?*\r\nNein! Zur Sicherheit solltest du allerdings immer deine Erziehungsberechtigten fragen. Alle Teilnehmer treten auf dem gleichen Niveau an, und alle Altersgruppen sind willkommen. In der Regel sind die meisten zwischen 10 und 20 Jahre alt, aber wir haben auch viele Teilnehmer, die älter oder jünger sind!\r\n\r\n* *Wie schnell muss ich den Würfel lösen, um teilnehmen zu können?*\r\nWir empfehlen, dass du dir die Tabs "Disziplinen" und "Zeitplan" ansiehst - wenn du das Zeitlimit für eine Disziplin, an der du gerne teilnehmen möchtest, normalerweise einhältst, dann bist du schnell genug! Viele Leute kommen nur zu den Wettbewerben, um ihre persönlichen Bestzeiten zu schlagen und Gleichgesinnte zu treffen, ohne die Absicht zu gewinnen oder auch nur die erste Runde zu überstehen.\r\n\r\n* *Kann ich Gäste mitbringen?*\r\nJa! Du hilfst uns bei der Organisation, wenn du bereits bei der Anmeldung die erwartete Anzahl Gäste angibst. Danke!\r\n\r\n* *Warum bin ich noch nicht auf der Anmeldeliste?*\r\nBitte überprüfe ob du die Anweisungen auf der Seite ["Anmelden"](https://www.worldcubeassociation.org/competitions/KoelnerKubing2023/register) komplett befolgt hast. Du könntest auch auf der Warteliste stehen. Das Teilnehmerlimit findest du auf der Seite "Allgemeine Info", und die Anzahl der bereits angemeldeten Teilnehmer kannst du auf der Seite "Teilnehmer" sehen. Wenn du alles richtig gemacht hast und das Teilnehmerlimit noch nicht erreicht wurde, habe bitte etwas Geduld. Wir müssen die Anmeldungen manuell genehmigen und die ehrenamtlichen Organisatoren sind nicht immer ununterbrochen erreichbar. Wenn du der Meinung bist, dass du die Schritte richtig befolgt hast, aber nach einigen Stunden immer noch nicht auf der Anmeldeliste stehst, dann schreib uns bitte eine E-Mail über den Kontaktlink auf dem "Allgemeine-Info"-Tab.\r\n\r\n* *Ich kann nicht mehr teilnehmen, was muss ich tun?*\r\nDu solltest uns so schnell wie möglich über den Kontaktlink auf der Seite "Allgemeine-Info" darüber informieren. Die Wettbewerbe sind in der Regel recht schnell ausgebucht, und wenn du uns mitteilst, dass du nicht mehr teilnehmen kannst, können wir jemanden von der Warteliste nachrücken lassen.\r\n\r\n* *Bekomme ich eine Rückerstattung, wenn ich nicht teilnehme?*\r\nWenn du uns mitteilst, dass du nicht mehr teilnehmen kannst bevor die Frist für die Rückerstattung auf der Seite "Allgemeine-Info" vorbei ist, dann erhältst du eine Rückerstattung. Wenn diese Frist verstrichen ist, erhältst du keine Rückerstattung mehr.\r\n\r\n* *Kann ich meine eigenen Würfel für den Wettbewerb verwenden?*\r\nJa! Auf Wettkämpfen werden keine Würfel zur Verfügung gestellt. Bring also für alle Disziplinen an denen du teilnimmst deine eigene Würfel mit und achte darauf, dass sie den Bedingungen im Regelwerk entsprechen.\r\n\r\n* *Kann ich nur zum Zuschauen kommen?*\r\nJa! Allerdings ist der Veranstaltungsort in der Regel insbesondere morgens ziemlich voll.\r\n\r\n* *Ich bin ein Elternteil, was kann ich tun, um mitzuhelfen?*\r\nWenn du etwas zu tun haben möchtest, dann kannst du beim Judging (schiedsrichtern der Teilnehmer) helfen! Dafür empfehlen wir zuvor das Tutorial für Neulinge gehört zu haben, wann dieses stattfindet steht im Tab "Zeitplan". Wir brauchen so gut wie immer Hilfe und die Abläufe sind wirklich einfach zu befolgen.\r\n\r\n* *Wann muss ich beim Wettbewerb ankommen?*\r\nWenn du ein neuer Teilnehmer bist empfehlen wir dir dringend zum "Tutorial for new competitors" zu kommen, das an beiden Tagen stattfindet. Andernfalls empfehlen wir dir, mindestens 20 Minuten vor deiner ersten Disziplin zu erscheinen (siehe Zeitplan). So hast du genug Zeit, um anzukommen, einen Platz zu finden und dich aufzuwärmen.\r\n\r\n* *Was muss ich tun, wenn ich ankomme?*\r\nWenn du ankommst, finde zuerst den Anmeldungs-Tisch auf, sofern die Anmeldung geöffnet ist. Normalerweise ist dieser direkt am Eingang, und erkannbar durch Namensschilder verteilt über den Tisch. Wenn du ankommst, bevor die Anmeldung geöffnet ist, warte bitte vor dem Raum bis wir die Türen öffnen. Wenn niemand am Anmeldeschalter ist, wende dich bitte an einen Organisator oder Delegate, und wir werden dafür sorgen, dass du dich anmelden kannst.\r\n\r\n* *Wann kann ich den Wettbewerb verlassen?*\r\nDu kannst jederzeit gehen, wann immer du willst. Wenn du keine weiteren Disziplinen mehr hast musst du nicht bleiben. Natürlich solltest du aber dann anwesend sein, wenn du zu Aufgaben wie z.B. Scrambling eingeteilt bist. ;)\r\n\r\n* *Wie kann ich die Ergebnisse einsehen?*\r\nAlle Ergebnisse werden einige Tage nach dem Wettbewerb auf dieser Seite zu finden sein, sobald sie überprüft und hochgeladen wurden. Wenn du nach Live-Ergebnissen suchst, gehe zu [WCA Live](https://live.worldcubeassociation.org/).\r\n\r\n* *Gibt es Preise zu gewinnen?*\r\nÜblicherweise erhalten die Podiumsplätze Urkunden, sollten wir darüber hinaus noch Preise überreichen, werden wir dies auf der Website kommunizieren.\r\n\r\n___\r\n\r\n### English\r\n\r\n* *How can I register?*\r\nFirst, make sure you have a valid **WCA account** (don\'t confuse this term with the *WCA-ID* and profile, which, if this is your first competition, you don\'t have yet). Login with your account, navigate to the competition page and click "Register". All further steps, including payment, are explained there. The most important points we still want to emphasize here as well: your registration is only complete after you filled the online form and payed the entry fee. Depending on when you registered completely, you can either obtain a spot on the competitor\'s list directly, or you will be placed on the waiting list if the maximum number of competitors has already been reached earlier. Only if someone cancels their registration, people on the waiting list can move up to the competitor\'s list. Which variant is the case for you, will be visible on a) the website and b) via personalized emails. Make sure your address is valid / a recent one to receive all information, update your address if necessary.\r\n\r\n* *I don\'t have a PayPal account, how can I pay the registration fee?*\r\nPlease reach out us via the contact form, and we will send you alternative ways to pay the fee.\r\n\r\n* *Is there a minimum age? Are there age categories?*\r\nNo! But if you are underage, make sure you have asked your parents who give permission for your participation. Everyone competes under the same regulations and there are no age categories, the majority of competitors is aged 10 to 20 years, but we often also have a lot of people younger or older than this age!\r\n\r\n* *How fast do I need to be?*\r\nWe suggest you take a look at "Events" and "Schedule" - if you usually make the specified timelimits for the respective categories, you are fast enough! Many people simply come to break their own personal records or meet likeminded cubers, without aiming for the win or proceeding to the next round.\r\n\r\n* *Can I bring guests?*\r\nYes! We\'d appreciate if you can inform us about the anticipated number of guests in advance by filling out the respective field in the registration form. Thanks!\r\n\r\n* *Why am I not on the competitor\'s list yet?*\r\nMake sure you followed all steps on the ["Register"](https://www.worldcubeassociation.org/competitions/KoelnerKubing2023/register) page. You might also be on the waiting list. The competitor limit is mentioned on the General info tab, and the number of currently registered people can be seen on the "Competitors" page. If you did everything correctly and the competitor limit has not been reached yet, be a little patient. We need to accept all registrations manually and organizers are not available 24/7. If you think that you did all required steps correctly, but even after several hours you can not find yourself on the competitor\'s list, please contact us via the contact email mentioned at the "General info" tab.\r\n\r\n* *I can not participate anymore, what do I need to do?*\r\nFirst you need to inform us as quickly as possible via the contact email mentioned at the "General info" tab. Usually, competitions fill very quickly, such that we would very much appreciate it if you tell us that you can not participate anymore. Someone else will be happy to move up from the waiting list.\r\n\r\n* *Do I get a refund if I can not participate anymore?*\r\nIf you inform us about this before the deadline for refunds (see "General info"), you will get a refund. Otherwise, after that deadline, no more refunds are possible.\r\n\r\n* *Can I use my own puzzles at the competition?*\r\nYes! At competitions, we do not provide the puzzles, instead make sure to bring puzzles for the events you are registered for and make sure they fulfil the criteria outlined in the regulations.\r\n\r\n* *Can I also just come as a spectator?*\r\nYes! However, the venue might be crowded at times, especially in the mornings.\r\n\r\n* *I am not participating myself, can I still help out with something?*\r\nIf you want to do something yourself to help out at the competition, you are welcome to help with judging the competitor\'s attempts! For this we recommend you join the competitor and judging tutorial in the morning (have a look at the schedule). Usually, we will be happy to receive any help during the day and this task can be learned quite quickly.\r\n\r\n* *When do I need to arrive for the competition?*\r\nIf you are a new competitor, please already arrive for the "Tutorial for new competitors", which will be held on both days. Otherwise, arriving 20 minutes before your first event (see schedule) is usually sufficient to grab a seat and warm up.\r\n\r\n* *What do I need to do when I arrive?*\r\nOnce you enter the venue, first stop by the registration desk, if the registration is open. Usually you will find a clearly visible table close to the entrance with several nametags distributed over the whole table. If you arrive before registration opens, please wait outside the building until we open the doors. If you don\'t arrive during the usual registration times in the morning and no one is currently at the registration desk, contact an organizer or delegate and we make sure you can properly register and receive your nametag.\r\n\r\n* *When can I leave the competition?*\r\nYou can leave at any time, if you don\'t participate in any further rounds you don\'t need to stay until the end. Just don\'t leave when you\'re assigned with any task like scrambling. ;)\r\n\r\n* *How can I view the results?*\r\nAll results will be available right here a couple days after the competition, after they have been checked and uploaded. While the competition is still running, you can view live results via [WCA Live](https://live.worldcubeassociation.org/).\r\n\r\n* *Can I win any prizes?*\r\nUsually, podium spots receive certificates. If there will be any prizes on top of that, we will communicate this clearly on the website.',
            display_order: 6,
          },
          {
            id: 31968,
            competition_id: 'KoelnerKubing2023',
            name: 'GCA',
            content:
              '[![](https://www.worldcubeassociation.org/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBcGNqIiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--3f93d32973ed5f3ad112f6e04ddc042b289f871c/Ohne%20Titel.jpg)](https://www.germancubeassociation.de/)\n\nAlle Wettkämpfe in Deutschland werden von Mitgliedern der [German Cube Association](https://www.germancubeassociation.de/) und weiteren freiwilligen Organisatoren aus dem ganzen Land durchgeführt. Bitte kommt auf uns zu, wenn auch ihr Interesse am Organisieren eines Turniers habt.\nAll competitions in Germany are run by members of the [German Cube Association](https://www.germancubeassociation.de/) and further voluntary organisers from all over the country. Please approach us if you are interested in hosting a competition.\n\nFolge uns auf unseren Social-Media-Seiten, um über die neuesten Inhalte und Ankündigungen auf dem Laufenden zu bleiben!\nFollow us on social media to stay up to date with new information and announcements!\n\n[![](https://www.worldcubeassociation.org/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBcEVqIiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--c465d8deba5509ea829e38813e375c7a7b846b3f/fFmmADt.png)](https://www.instagram.com/germancubeassociation/) [![](https://www.worldcubeassociation.org/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBcFVqIiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--500c3d9550cb8161085be58845afbf73b50190e7/Bildschirmfoto%202022-09-25%20um%2012.08.41.png)](https://www.twitch.tv/germanonlinecubing2020/)',
            display_order: 7,
          },
        ],
        'class': 'competition',
      }
    when "FMCFrance2023"
      {
        'id': 'FMCFrance2023',
        'name': 'FMC France 2023',
        'information':
          "Merci de **lire attentivement les conditions d'inscription, la [FAQ](#34417-faq) et les [tutoriels AFS](https://www.speedcubingfrance.org/speedcubing/tutos)**. \r\nPensez également à consulter l'onglet [Planning](#competition-schedule). \r\n**ATTENTION** Cette compétition n'est PAS une compétition classique. Il n'y aura qu'une seule épreuve : la résolution optimisée (Fewest Moves), pendant laquelle la solution la plus courte à un mélange donné doit être trouvée et écrite sur une feuille en un temps maximum d'une heure. **Il n'y aura pas de 3x3 classique lors de cette compétition.**\r\n \r\n----\r\nPlease **read the registration conditions, the [FAQ](#34417-faq) et the [AFS tutorials](https://www.speedcubingfrance.org/speedcubing/tutos) carefully**.\r\nMake sure to read the [Schedule](#competition-schedule) tab. \r\n**WARNING**  This competition is NOT a regular competition. There will be only one event: Fewest Moves, in which the shortest solution to a given scramble must be found and written on a sheet of paper in a maximum of one hour. **There will be no 3x3 in this competition.**",
        'venue': 'Lieux multiples / Multiple locations',
        'contact': '',
        'registration_open': self.date_from_now(-1),
        'registration_close': self.date_from_now(0, 2),
        'use_wca_registration': true,
        'announced_at': '2023-10-11T21:56:10.000Z',
        'base_entry_fee_lowest_denomination': 500,
        'currency_code': 'EUR',
        'start_date': '2023-11-18',
        'end_date': '2023-11-18',
        'enable_donations': true,
        'competitor_limit': nil,
        'extra_registration_requirements':
          "###**[FRANÇAIS]**\r\n\r\n**Vous devez préciser en commentaire la ville dans laquelle vous souhaitez participer afin que votre inscription soit considérée comme valide.**\r\n\r\nAvant la compétition l'équipe d'organisation est susceptible de vous envoyer un ou plusieurs e-mails. Merci de bien vouloir répondre dans les délais, une absence de réponse pourrait nous conduire à supprimer votre inscription s'il y a une liste d'attente.\r\n\r\nSi vous êtes **adhérent·e AFS** ou que c'est votre **première compétition**, l'inscription est **gratuite**, vous n'avez donc pas à payer en ligne (même si la page de paiement s'affiche). Attendez tout simplement qu'on accepte votre inscription.\r\nPlus d'informations [ici](http://www.speedcubingfrance.org/news/2018-03-05-wca-dues-system).\r\n\r\n**LES INSCRIPTIONS SONT TRAITÉES MANUELLEMENT et peuvent donc prendre un peu de temps**, merci de votre patience.\r\nLes inscriptions sont acceptées dans l'ordre où elles nous arrivent complètes, ce qui signifie :\r\n\r\n- Pour les personnes qui n'ont pas besoin de payer, nous prenons en compte l'heure à laquelle la personne s'est **inscrite**.\r\n-  Pour les personnes qui doivent payer, nous prenons en compte l'heure a laquelle la personne a **payé.**\r\n\r\nNotez que vous resterez sur liste d'attente tant que votre inscription n'est pas valide. Si vous êtes dans le cas où un paiement est nécessaire, notez bien que vous ne pourrez quittez la liste d'attente que si votre paiement est effectué et que le nombre limite de participant·e·s n'est pas atteint (ou que quelqu'un se désiste).\r\nNous rembourserons les personnes qui seront restées sur liste d'attente après la compétition.\r\n\r\nN'hésitez pas à faire un don lors de votre inscription pour soutenir l'AFS afin de permettre à cette dernière d'acheter et de renouveler le matériel français.\r\n\r\n---\r\n###**[ENGLISH]**\r\n\r\n**You must specify in your comment the city in which you wish to participate so that your registration is considered valid.**\r\n\r\nBefore the competition, the organisation team may send you one or multiple emails. Please answer them in time. Not answering to these mails might make us delete your registration, if there is a waiting list.\r\n\r\nIf you're an **AFS member** or if it's your **first competition**, the competition is **free**, you don't need to pay online (even if the payment page shows up). Just wait for us to accept your registration.\r\nFor more information, please click [here](http://www.speedcubingfrance.org/news/2018-03-05-wca-dues-system) (in French, please contact organizers if you have questions).\r\n\r\n**REGISTRATIONS ARE HANDLED MANUALLY and can take a bit of time**, thank you for your patience.\r\nRegistrations are accepted in the order that the registration is completed, which means :\r\n\r\n- For the people who don't need to pay, we take into account the time when the person **registered.**\r\n- For the people who need to pay, we take into account the time when the person **paid.**\r\n\r\nYou will stay on the waiting list until your registration is valid. If you are required to pay an entrance fee, please note that your registration will be eligible to leave the waiting list only if you've paid and the competitors limit has not been reached (or if someone deletes their registration).\r\nWe will refund your registration if you did not leave the waiting list after the competition.\r\n\r\nDo not hesitate to make a donation in order to support the AFS and allow it to buy and renew the French equipment.",
        'on_the_spot_registration': true,
        'on_the_spot_entry_fee_lowest_denomination': 500,
        'refund_policy_percent': 100,
        'refund_policy_limit_date': self.date_from_now(0, 2),
        'guests_entry_fee_lowest_denomination': 0,
        'qualification_results': false,
        'external_registration_page': '',
        'event_restrictions': false,
        'cancelled_at': nil,
        'waiting_list_deadline_date': self.date_from_now(0, 1),
        'event_change_deadline_date': self.date_from_now(0, 1),
        'guest_entry_status': 'free',
        'allow_registration_edits': false,
        'allow_registration_self_delete_after_acceptance': true,
        'allow_registration_without_qualification': false,
        'guests_per_registration_limit': nil,
        'force_comment_in_registration': true,
        'url': 'https://www.worldcubeassociation.org/competitions/FMCFrance2023',
        'website': 'https://www.worldcubeassociation.org/competitions/FMCFrance2023',
        'short_name': 'FMC France 2023',
        'city': 'Lieux multiples / Multiple locations',
        'venue_address': 'Lieux multiples / Multiple locations',
        'venue_details': '',
        'latitude_degrees': 46.53924,
        'longitude_degrees': 2.430189,
        'country_iso2': 'FR',
        'event_ids': ['333fm'],
        'registration_opened?': true,
        'main_event_id': '333fm',
        'number_of_bookmarks': 20,
        'using_stripe_payments?': false,
        'uses_qualification?': false,
        'uses_cutoff?': false,
        'delegates': [
          {
            id: 1436,
            created_at: '2015-08-09T23:32:23.000Z',
            updated_at: '2023-10-21T12:02:52.000Z',
            name: 'Hippolyte Moreau',
            delegate_status: 'candidate_delegate',
            wca_id: '2008MORE02',
            gender: 'm',
            country_iso2: 'FR',
            url: 'https://www.worldcubeassociation.org/persons/2008MORE02',
            country: {
              id: 'France',
              name: 'France',
              continentId: '_Europe',
              iso2: 'FR',
            },
            email: 'hmoreau@worldcubeassociation.org',
            location: 'France',
            senior_delegate_id: 454,
            class: 'user',
            teams: [],
            avatar: {
              url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2008MORE02/1684788096.jpg',
              pending_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              thumb_url:
                'https://avatars.worldcubeassociation.org/uploads/user/avatar/2008MORE02/1684788096_thumb.jpg',
              is_default: false,
            },
          },
          {
            id: 1517,
            created_at: '2015-08-15T15:50:19.000Z',
            updated_at: '2023-10-10T20:11:25.000Z',
            name: 'Antoine Piau',
            delegate_status: 'delegate',
            wca_id: '2008PIAU01',
            gender: 'o',
            country_iso2: 'FR',
            url: 'https://www.worldcubeassociation.org/persons/2008PIAU01',
            country: {
              id: 'France',
              name: 'France',
              continentId: '_Europe',
              iso2: 'FR',
            },
            email: 'apiau@worldcubeassociation.org',
            location: 'France',
            senior_delegate_id: 454,
            class: 'user',
            teams: [],
            avatar: {
              url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2008PIAU01/1683815649.png',
              pending_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              thumb_url:
                'https://avatars.worldcubeassociation.org/uploads/user/avatar/2008PIAU01/1683815649_thumb.png',
              is_default: false,
            },
          },
          {
            id: 11959,
            created_at: '2016-02-15T10:17:28.000Z',
            updated_at: '2023-10-30T18:40:01.000Z',
            name: 'Jules Desjardin',
            delegate_status: 'candidate_delegate',
            wca_id: '2010DESJ01',
            gender: 'm',
            country_iso2: 'FR',
            url: 'https://www.worldcubeassociation.org/persons/2010DESJ01',
            country: {
              id: 'France',
              name: 'France',
              continentId: '_Europe',
              iso2: 'FR',
            },
            email: 'jdesjardin@worldcubeassociation.org',
            location: 'France',
            senior_delegate_id: 454,
            class: 'user',
            teams: [
              {
                id: 505,
                friendly_id: 'wdc',
                leader: false,
                name: 'Jules Desjardin',
                senior_member: true,
                wca_id: '2010DESJ01',
                avatar: {
                  url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2010DESJ01/1504739091.JPG',
                  thumb: {
                    url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2010DESJ01/1504739091_thumb.JPG',
                  },
                },
              },
            ],
            avatar: {
              url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2010DESJ01/1504739091.JPG',
              pending_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              thumb_url:
                'https://avatars.worldcubeassociation.org/uploads/user/avatar/2010DESJ01/1504739091_thumb.JPG',
              is_default: false,
            },
          },
          {
            id: 25588,
            created_at: '2016-08-02T16:12:52.000Z',
            updated_at: '2023-10-30T23:44:55.000Z',
            name: 'Rubén López de Juan',
            delegate_status: 'delegate',
            wca_id: '2016LOPE37',
            gender: 'm',
            country_iso2: 'ES',
            url: 'https://www.worldcubeassociation.org/persons/2016LOPE37',
            country: {
              id: 'Spain',
              name: 'Spain',
              continentId: '_Europe',
              iso2: 'ES',
            },
            email: 'rjuan@worldcubeassociation.org',
            location: 'Spain',
            senior_delegate_id: 454,
            class: 'user',
            teams: [],
            avatar: {
              url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2016LOPE37/1683710938.jpg',
              pending_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              thumb_url:
                'https://avatars.worldcubeassociation.org/uploads/user/avatar/2016LOPE37/1683710938_thumb.jpg',
              is_default: false,
            },
          },
          {
            id: 46689,
            created_at: '2017-02-18T14:52:38.000Z',
            updated_at: '2023-10-28T22:37:42.000Z',
            name: 'Alexandre Ondet',
            delegate_status: 'candidate_delegate',
            wca_id: '2017ONDE01',
            gender: 'm',
            country_iso2: 'FR',
            url: 'https://www.worldcubeassociation.org/persons/2017ONDE01',
            country: {
              id: 'France',
              name: 'France',
              continentId: '_Europe',
              iso2: 'FR',
            },
            email: 'aondet@worldcubeassociation.org',
            location: 'Canada (Quebec)',
            senior_delegate_id: 705,
            class: 'user',
            teams: [],
            avatar: {
              url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2017ONDE01/1667253702.jpeg',
              pending_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              thumb_url:
                'https://avatars.worldcubeassociation.org/uploads/user/avatar/2017ONDE01/1667253702_thumb.jpeg',
              is_default: false,
            },
          },
        ],
        'organizers': [
          {
            id: 1436,
            created_at: '2015-08-09T23:32:23.000Z',
            updated_at: '2023-10-21T12:02:52.000Z',
            name: 'Hippolyte Moreau',
            delegate_status: 'candidate_delegate',
            wca_id: '2008MORE02',
            gender: 'm',
            country_iso2: 'FR',
            url: 'https://www.worldcubeassociation.org/persons/2008MORE02',
            country: {
              id: 'France',
              name: 'France',
              continentId: '_Europe',
              iso2: 'FR',
            },
            email: 'hmoreau@worldcubeassociation.org',
            location: 'France',
            senior_delegate_id: 454,
            class: 'user',
            teams: [],
            avatar: {
              url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2008MORE02/1684788096.jpg',
              pending_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              thumb_url:
                'https://avatars.worldcubeassociation.org/uploads/user/avatar/2008MORE02/1684788096_thumb.jpg',
              is_default: false,
            },
          },
          {
            id: 1517,
            created_at: '2015-08-15T15:50:19.000Z',
            updated_at: '2023-10-10T20:11:25.000Z',
            name: 'Antoine Piau',
            delegate_status: 'delegate',
            wca_id: '2008PIAU01',
            gender: 'o',
            country_iso2: 'FR',
            url: 'https://www.worldcubeassociation.org/persons/2008PIAU01',
            country: {
              id: 'France',
              name: 'France',
              continentId: '_Europe',
              iso2: 'FR',
            },
            email: 'apiau@worldcubeassociation.org',
            location: 'France',
            senior_delegate_id: 454,
            class: 'user',
            teams: [],
            avatar: {
              url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2008PIAU01/1683815649.png',
              pending_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              thumb_url:
                'https://avatars.worldcubeassociation.org/uploads/user/avatar/2008PIAU01/1683815649_thumb.png',
              is_default: false,
            },
          },
          {
            id: 11959,
            created_at: '2016-02-15T10:17:28.000Z',
            updated_at: '2023-10-30T18:40:01.000Z',
            name: 'Jules Desjardin',
            delegate_status: 'candidate_delegate',
            wca_id: '2010DESJ01',
            gender: 'm',
            country_iso2: 'FR',
            url: 'https://www.worldcubeassociation.org/persons/2010DESJ01',
            country: {
              id: 'France',
              name: 'France',
              continentId: '_Europe',
              iso2: 'FR',
            },
            email: 'jdesjardin@worldcubeassociation.org',
            location: 'France',
            senior_delegate_id: 454,
            class: 'user',
            teams: [
              {
                id: 505,
                friendly_id: 'wdc',
                leader: false,
                name: 'Jules Desjardin',
                senior_member: true,
                wca_id: '2010DESJ01',
                avatar: {
                  url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2010DESJ01/1504739091.JPG',
                  thumb: {
                    url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2010DESJ01/1504739091_thumb.JPG',
                  },
                },
              },
            ],
            avatar: {
              url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2010DESJ01/1504739091.JPG',
              pending_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              thumb_url:
                'https://avatars.worldcubeassociation.org/uploads/user/avatar/2010DESJ01/1504739091_thumb.JPG',
              is_default: false,
            },
          },
          {
            id: 25588,
            created_at: '2016-08-02T16:12:52.000Z',
            updated_at: '2023-10-30T23:44:55.000Z',
            name: 'Rubén López de Juan',
            delegate_status: 'delegate',
            wca_id: '2016LOPE37',
            gender: 'm',
            country_iso2: 'ES',
            url: 'https://www.worldcubeassociation.org/persons/2016LOPE37',
            country: {
              id: 'Spain',
              name: 'Spain',
              continentId: '_Europe',
              iso2: 'ES',
            },
            email: 'rjuan@worldcubeassociation.org',
            location: 'Spain',
            senior_delegate_id: 454,
            class: 'user',
            teams: [],
            avatar: {
              url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2016LOPE37/1683710938.jpg',
              pending_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              thumb_url:
                'https://avatars.worldcubeassociation.org/uploads/user/avatar/2016LOPE37/1683710938_thumb.jpg',
              is_default: false,
            },
          },
          {
            id: 46689,
            created_at: '2017-02-18T14:52:38.000Z',
            updated_at: '2023-10-28T22:37:42.000Z',
            name: 'Alexandre Ondet',
            delegate_status: 'candidate_delegate',
            wca_id: '2017ONDE01',
            gender: 'm',
            country_iso2: 'FR',
            url: 'https://www.worldcubeassociation.org/persons/2017ONDE01',
            country: {
              id: 'France',
              name: 'France',
              continentId: '_Europe',
              iso2: 'FR',
            },
            email: 'aondet@worldcubeassociation.org',
            location: 'Canada (Quebec)',
            senior_delegate_id: 705,
            class: 'user',
            teams: [],
            avatar: {
              url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2017ONDE01/1667253702.jpeg',
              pending_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              thumb_url:
                'https://avatars.worldcubeassociation.org/uploads/user/avatar/2017ONDE01/1667253702_thumb.jpeg',
              is_default: false,
            },
          },
          {
            id: 63595,
            created_at: '2017-06-29T17:28:44.000Z',
            updated_at: '2023-10-26T19:10:53.000Z',
            name: 'Baptiste Hennuy',
            delegate_status: nil,
            wca_id: '2018HENN02',
            gender: 'm',
            country_iso2: 'FR',
            url: 'https://www.worldcubeassociation.org/persons/2018HENN02',
            country: {
              id: 'France',
              name: 'France',
              continentId: '_Europe',
              iso2: 'FR',
            },
            class: 'user',
            teams: [],
            avatar: {
              url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2018HENN02/1578238216.jpg',
              pending_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              thumb_url:
                'https://avatars.worldcubeassociation.org/uploads/user/avatar/2018HENN02/1578238216_thumb.jpg',
              is_default: false,
            },
          },
        ],
        'tabs': [
          {
            id: 34420,
            competition_id: 'FMCFrance2023',
            name: 'IMPORTANT',
            content:
              "**[Français]** \r\nCette compétition n'est PAS une compétition classique. Il n'y aura qu'une seule épreuve : la résolution optimisée (Fewest Moves), pendant laquelle la solution la plus courte à un mélange donné doit être trouvée et écrite sur une feuille en un temps maximum d'une heure. **Il n'y aura pas de 3x3 classique lors de cette compétition.**\r\nAutre particularité : cette compétition se déroule à plusieurs endroits en même temps. Il est donc primordial que vous nous communiquiez la ville dans laquelle vous souhaitez participer pour que l'on puisse anticiper le nombre de personnes présentes à chaque endroit. Pour cela, **merci d'indiquer la ville où vous comptez aller en commentaire de votre inscription**. Votre inscription ne sera considérée complète que si vous nous donnez la ville.\r\nLe planning indique que le top 75% passera en finale. Notez que ce top 75% concerne l'ensemble des lieux et pas seulement sur le lieu où vous participerez.\r\n\r\n---\r\n\r\n**[English]**\r\nThis competition is NOT a regular competition. There will be only one event: Fewest Moves, in which the shortest solution to a given scramble must be found and written on a sheet of paper in a maximum of one hour. **There will be no 3x3 in this competition.**\r\nAnother particularity: this competition takes place in several places at the same time. It is therefore essential that you let us know the city in which you wish to participate so that we can anticipate the number of people present at each location. For this, **please indicate the city where you intend to go in the comments of your registration**. Your registration will only be considered complete if you give us the city.\r\nThe schedule indicates that the top 75% will advance to the final. Note that this top 75% concerns all locations and not just the location where you will participate.\r\n\r\n---\r\n\r\n**[Brezhoneg]**\r\nAr genstrivaged-mañ n'eo KET ur genstrivadeg kustum. Ne vo nemet ur genstrivadenn: an diluziadur gwellekaet, da lavaret eo kavout ha skrivañ an dilaziadur ar berrañ evit ur meskad roet e-pad un eurvezh d'ar muiañ. **Ne vo 3x3 ebet e-pad ar genstrivadeg-mañ**\r\nDibarded all: ar genstrivadeg-mañ a vo aozet e meur a lec'h er memes amzer. Neuze, pouezus eo lavar deomp pelec'h ho peus c'hoant kemer perzh evit gouzout pegement a zud a vo e pep lec'h. Evit-se, **trugarez da skrivañ ar gêr ho peus c'hoant da vont en evezhiadenn hoc'h enskrivadur**. Klok 'vo hoc'h enskrivadur hepken goude bezañ roet ar gêr deomp.\r\nEr planig e vez lavaret ez ay ar 75% gwellañ er gourfenn. Se a zo ouzh an holl lec'hioù ha n'eo ket ouzh al lec'h ma kemerit perzh nemetken.\r\n\r\n---\r\n\r\n**[Galo]**\r\nLa course-la n'ét POUINT une course coutumiere. N-i ara ren q'un assaot : le 3x3x3 en le meins de mouvements possibl, a savair terouer le mouayen de fére le qhube o le meins de mouvements possibl e l'ecrire en mouins d'une oure. **N-i ara don pouint de 3x3 coutumier den la course-la.**\r\nAotr cai pouint coutumier : la course-la sera a puzieurs endrets en méme temp. Faot don qe vous nous diziéz eyou qe vous vouléz veni prendr part a sour fin qe je sachions comben de jiens vont étr a châqe endrët. Pour ela, **merci de nous dire la vile eyou qe vous vouléz veni en mencion de votr enlistaije**. Votr enlistaije sera valabl seulement cant qe je saurons la vile eyou qe vous vouléz veni.\r\nLe programe ensegne qe les meillous 75% pount aler en finale. Les meillous 75%-la sont su tous les leûs d'ensembl, pâs ren qe l'endret eyou qe vous serez.\r\n\r\n---\r\n\r\n**[Arpetan]**\r\nCeta compèticion est PAS una compèticion classica. Il n'y arat qu'una solèta èprôva : la rèsolucion optimisâye (Fewest Moves). La solucion més côrta a un mècllo balyê dêt étre trovâ et ècrita sur una fôlye en un temps maximon d'una hora. **Il y arat pas de 3x3 classico durent ceta compèticion.**\r\nÔtra particularitât : ceta compèticion sè pâsse a plusiors endrêts en mémo temps. Il est donc primordial que vos nos comunicâvâd la vela dens que vos souhètâd participar por qu'on pouesse prèvêre lo nombro de pèrsones presentes a châque endrêt. Por cen, **marci d'endicar la vela yô que vos comptâd alar en comentèro de voutra enscripcion**. Voutra enscripcion serat considèrâye complèta que se vos nos balyéd la vela.\r\nLo planning endique que lo pèrfêt 75% passerat en finâla. Notâd que ceti pèrfêt 75% regârde l'ensemblo des luès et pas solament sur lo luè yô que vos participeréd.\r\n\r\n---\r\n\r\n**[Occitan]**\r\nAquela competicion es PAS una competicion classica. I aurà pas qu'una sola espròva : la resolucion optimizada (Fewest Moves), pendent la quala la solucion mai corta a una mescla balhada deu èsser trobada e escricha sus una fuèlha en un temps maximum d'una ora. **I aurà pas de 3x3 classic pendent aquela competicion.**\r\nAutra particularitat : aquela competicion se debana a mantun endrech a l'encòp. Es donc primordial que nos comunicàvetz la vila dins la quala desiratz participar per que se pòsca anticipar lo nombre de personas presentas a cada endrech. Per aquò, **mercé d'indicar la vila ont comptatz anar en comentari de vòstra inscripcion**. Vòstra inscripcion serà pas considerada complèta que se nos balhatz la vila.\r\nLa planificacion indica que lo tòp 75% passarà en finala. Notatz qu'aquel tòp 75% concernís l'ensemble dels luòcs e pas solament sul luòc ont participaretz.\r\n\r\n---\r\n\r\n**[Euskara]**\r\nTxapelketa hau ez da txapelketa arrunt bat. Bakarrik kategoria bat izango du: kuboaren soluzio optimizatuta aurkitzea eta paperrezko orri batean idaztea, ordu bateko denbora maximoan. **Ez da 3x3 kubo klasikoa egongo txapelketa honetan**. Beste bitxikeria bat, txapelketa hau hainbat lekutan ospatuko da, beraz, izena ematean, mesedez **egongo zaren lekua adierazi iruzkinetan.**\r\nHiria idazten ez baduzu, izen ematea ez da burututa hartuko.\r\n\r\n---\r\n\r\n**[Esperanto]**\r\nĈi tiu konkurso NE estas normala konkurso. Estos nur unu konkursero: la optimumigita rezolucio, dum kiu la plej mallonga solvo al difinita miksaĵo devas esti trovita kaj skribita sur folio en maksimuma tempo de unu horo. **Ne estos normala 3x3 dum ĉi tiu konkurso.**\r\nAlia nenormalaĵo: ĉi tiu konkurso okazas en pluraj lokoj samtempe. Necesas do, ke vi diru al ni la urbon, en kiu vi volas partopreni, por ke ni povu antaŭvidi la nombron da ĉeestantoj ĉe ĉiu loko. Por fari tion, **bonvolu indiki la urbon, kien vi planas iri en la komento de via registriĝo**. Via registriĝo estos konsiderata kompleta nur se vi donas al ni la urbon.\r\nLa horplano indikas ke la unuaj 75% kvalifikas en la sekva raŭndo. Notu ke ĉi tiuj unuaj 75% koncernas ĉiujn lokojn kaj ne nur la lokon kie vi partoprenos.",
            display_order: 1,
          },
          {
            id: 34416,
            competition_id: 'FMCFrance2023',
            name: 'Lieux | Locations',
            content:
              "**[Français]** Les adresses précises seront envoyées plus tard par email.\r\n**[English]** The precise addresses will be sent later by email.\r\n**[Brezhoneg]** Roet e vo chomlec'hoù resis diwezatoc'h dre bostel.\r\n**[Galo]** Un limessaije sera aboutë pus tard un ptit a sour fin de donner les vraes aderces.\r\n**[Arpetan]** Les adrèces prècises seront envoyêes més târd per email.\r\n**[Occitan]** Las adreças precisas seràn enviadas mai tard per email.\r\n**[Euskara]** Helbide zehatzak geroago bidaliko dira emailez.\r\n**[Esperanto]** La precizaj adresoj estos senditaj poste retpoŝte.\r\n\r\n| Ville / City / Urbo | Code Postal / ZIP Code / Poŝtkodo | Compétiteurs inscrits / Registered competitors / Registritaj partoprenantoj | Nombre limite de compétiteurs / Competitors limit / Limo da partoprenantoj | Délégué / Delegate | \r\n| -------- | -------- | -------- | -------- | -------- |\r\n| Grenoble / Grenoblo | 38000 | 4 | 10 | Hippolyte Moreau | \r\n| La Montagne / Ar Menez | 44620 | 3 | 12 | Antoine Piau | \r\n| Marseille / Marselha | 13000 | 9 | 9     | Jules Desjardin | \r\n| Pau | 64000 | 8 | 10 | Rubén López de Juan |\r\n| Tallende | 63450 | 2 | 20     | Alexandre Ondet | \r\n\r\n![](https://www.worldcubeassociation.org/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBaTFWIiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--fc2267465fe35a15fc8dd208c19c1be66c481967/image.png)",
            display_order: 2,
          },
          {
            id: 34417,
            competition_id: 'FMCFrance2023',
            name: 'FAQ ',
            content:
              "*[English below]\r\n[Esperanto malsupre]*\r\n\r\n###**[Français]**\r\n\r\n**Q : Comment je m’inscris ?**\r\n**R :** Tout d’abord, vous devez créer un compte sur le site de la WCA. Vous pouvez le faire en cliquant sur *[Inscription](https://www.worldcubeassociation.org/users/sign_up)*. Une fois que vous avez créé votre compte et confirmé votre adresse mail, allez dans l’onglet *[S’inscrire](https://www.worldcubeassociation.org/competitions/FMCFrance2023/register)* de la compétition qui vous intéresse, lisez et suivez les instructions attentivement.\r\n\r\n**Q : Pourquoi ne suis-je pas sur la liste des compétiteurs ?**\r\n**R :** Merci de vous assurer d’avoir bien lu et suivi les instructions présentes dans la section *[S’inscrire](https://www.worldcubeassociation.org/competitions/FMCFrance2023/register)* de la compétition. Notamment, si vous n’êtes pas adhérent.e à l’AFS (voir [ici](https://www.speedcubingfrance.org/association/adhesion)), et que ce n’est pas votre première compétition, merci de vérifier que vous avez bien payé la compétition. Il est aussi possible que vous soyez sur liste d’attente. Le nombre maximum de participant.e.s peut être trouvé sur la page principale de la compétition (onglet *[Informations générales](#general-info)*) et vous pouvez voir le nombre de personnes déjà acceptées sur la page *[Compétiteurs](https://www.worldcubeassociation.org/competitions/FMCFrance2023/registrations)* de la compétition. Si vous avez tout fait correctement, payé si nécessaire, et que la compétition n’est pas remplie, soyez patient.e.s. Nous devons accepter manuellement les inscriptions et les équipes d’organisation ne sont pas disponibles tout le temps. Si vous pensez avoir tout fait correctement mais que vous n’êtes toujours pas accepté.e après deux jours, alors contactez nous en cliquant sur le lien *Contact* présent sur la page principale de la compétition, onglet *[Informations générales](#general-info)*.\r\n\r\n**Q : Je suis adhérent.e à l’AFS, ou c’est ma première compétition, et le site me demande quand même de payer, que faire ?**\r\n**R :** Comme indiqué sur la page de la compétition, pas besoin de payer ! Le site de la WCA fait apparaître par défaut la page de paiement puisqu'il ne peut pas savoir si votre inscription est payée par l'AFS ou non mais, rassurez-vous, l'équipe d'organisation le saura, contrôlera qui a besoin de payer et qui n'a pas besoin, et tiendra donc bien compte de cette donnée au moment de valider les inscriptions.\r\nSi vous n'êtes pas certains d'être adhérent.e à l'AFS, vérifiez en vous connectant sur le site de l'association puis en allant dans votre profil.\r\n\r\n**Q : Est-ce que je peux changer les épreuves auxquelles je me suis inscrit.e ?**\r\n**R :** Si l'équipe d'organisation l'a autorisé, vous pouvez changer vos épreuves ici jusqu'à la fin de la période d'inscription. Si ce n'est pas le cas, vous pouvez directement contacter l'équipe d'organisation via le lien *Contact* sur l'onglet *[Informations générales](#general-info)*.\r\n\r\n**Q : Je ne peux plus venir à la compétition ? Que dois-je faire ?**\r\n**R :** Merci de nous prévenir dès que vous savez que vous ne pouvez plus venir, en nous envoyant un mail en cliquant sur le lien *Contact* présent sur la page principale de la compétition, onglet *[Informations générales](#general-info)*. Les compétitions se remplissent généralement assez vite et nous prévenir de votre désinscription nous permet d’accepter quelqu’un de la liste d’attente. Votre paiement vous sera remboursé si vous vous désinscrivez avant la date inscrite sur la page des *[Informations générales](#general-info)*.\r\n\r\n**Q : Est-ce que je dois être très rapide pour pouvoir participer ?**\r\n**R :** Nous vous recommandons de regarder la page *[Planning](#competition-schedule)* de la compétition. Pour chaque épreuve, si vous pouvez résoudre le cube plus rapidement que le temps indiqué en *Time limit*, vous êtes assez rapide ! Les épreuves généralement appréciées des débutants (3x3, 2x2, pyraminx, skewb) ont la plupart du temps une *Time limit* de 10 minutes, ce qui laisse à une grande majorité de compétiteurs la possibilité de participer. Beaucoup de personnes viennent en compétition dans le seul but de s’amuser et de battre leurs propres records, sans s’attendre à gagner\r\n\r\n**Q : Y a-t-il différentes catégories ?**\r\n**R :** Tous les compétiteurs et les compétitrices participent ensemble et tous les âges, genres, nationalités sont acceptés en compétition. \r\n\r\n**Q : Est-ce que je dois participer à toutes les épreuves ?**\r\n**R :** Non. Il y a un classement pour chaque épreuve. Vous pouvez donc participer à celles qui vous plaisent uniquement. Il faudra pour cela sélectionner les bonnes images lors de votre inscription.\r\n\r\n**Q : Dois-je utiliser mes propres cubes pour participer ?**\r\n**R :** Oui ! Assurez vous d’apporter au moins un cube pour chaque épreuve à laquelle vous vous êtes inscrit.e.s et faites-y bien attention au cours de la compétition. Les vols sont très rares mais il est courant de prendre un cube similaire au sien sans y prêter attention.\r\nAssurez-vous cependant que votre cube est autorisé. Les cubes connectés ou encore les cubes avec plusieurs logos sont interdits pour les essais officiels. Également, notez que tout cube avec logo (même s'il n'y en a qu'un et qu'on ne \\'peut pas le sentir au toucher\\') est interdit pour les épreuves à l'aveugle.\r\n\r\n**Q : Est ce que je peux venir seulement en tant que spectateur ou spectatrice ?**\r\n**R :** Oui, sauf indication contraire dans les Informations Générales de la compétition, les compétitions sont accessibles gratuitement. Vous pouvez regarder l’onglet *[Planning](#competition-schedule)* pour regarder les horaires de passage des épreuves qui vous intéressent. \r\n\r\n**Q : A quelle heure dois-je arriver pour la compétition ?**\r\n**R :** Si c’est votre première compétition, nous vous conseillons de regarder sur le *[Planning](#competition-schedule)* l’heure du tutoriel, et d’arriver environ 20 minutes avant. Dans le cas contraire, merci d’arriver à la compétition environ 30 minutes avant le début de votre première épreuve. Merci de noter que si vous arrivez après la fin d’une de vos épreuves, nous ne pourrons pas vous faire rattraper.\r\n\r\n**Q : Que dois-je faire en arrivant à la compétition ?**\r\n**R :** La première chose à faire est de trouver l’accueil et de vous présenter. Si vous êtes nouveau compétiteur ou nouvelle compétitrice, pensez à prendre avec vous une pièce d’identité (ou tout document mentionnant vos nom, prénom et date de naissance) car elle vous sera demandée à l’accueil. La personne qui vous accueillera pourra ensuite vous guider et répondre à vos premières questions.\r\n\r\n**Q : Quand est-ce que je peux partir de la compétition ?**\r\n**R :** Il est seulement nécessaire d’être présent.e lorsque vous devez participer ou juger / runner / mélanger (un planning individuel vous sera probablement remis à l’entrée de la compétition). Une fois que vous n’avez plus de tâches, vous êtes libres de partir. Pensez quand même à vérifier si vous vous êtes qualifié.e.s pour un autre tour, on ne sait jamais !\r\n\r\n**Q : Où est ce que je peux trouver les résultats ?**\r\n**R :** Durant la compétition, les résultats sont entrés manuellement sur *[WCA Live](https://live.worldcubeassociation.org/)* et sont disponibles en ligne environ une demie heure après la fin de chaque tour. \r\nA la fin de la compétition, tous les résultats seront disponibles sur cette page. \r\n\r\n**Q : Comment créer mon identifiant WCA ?**\r\n**R :** Les identifiants sont créés automatiquement dès la publication des résultats (moins d’une semaine après la fin de la compétition). Le format est : Année de la première compétition – 4 premières lettres du nom de famille – deux chiffres servant à différencier les personnes qui auraient les mêmes informations.\r\n\r\n**Q : J’ai l’habitude de m'entraîner en écoutant de la musique. Puis-je utiliser un casque lors de mes essais officiels ?**\r\n**R :** Les casques audios ou les écouteurs sont strictement interdits durant les essais officiels, leur utilisation entraînerait donc une disqualification des essais concernés. Si le casque vous sert à être plus concentré ou moins stressé, alors vous pouvez utiliser un casque anti-bruit à l'unique condition qu'il soit sans aucun composant électronique.\r\n\r\n**Q : Est ce que je peux filmer mes résolutions ?**\r\n**R :** C’est tout à fait possible, avec une caméra sur pied (gopro ou autre) ou un téléphone portable. Attention cependant : dans le cas d’un téléphone portable ou d’un appareil avec un écran, celui-ci ne doit pas être dirigé vers vous. Une fois que la résolution commence, c’est à dire dès que l’inspection a commencé, il est strictement interdit de toucher à sa caméra, même si elle tombe, sous peine de disqualification de la résolution (DNF).\r\n\r\n_________________\r\n\r\n###**[English]**\r\n\r\n**Q: How do I register?**\r\n**A:** First you need to make sure you have created a WCA account. You can do this by going to the *[Sign-up](https://www.worldcubeassociation.org/users/sign_up)* page and creating an account. Once you have created the account and confirmed your email address, go to the *[Register](https://www.worldcubeassociation.org/competitions/FMCFrance2023/register)* section of the competition and follow the instructions carefully.\r\n\r\n**Q: Why am I not on the registration list yet?**\r\n**A:** Please make sure that you have carefully read and followed the instructions in the *[Register](https://www.worldcubeassociation.org/competitions/FMCFrance2023/register)* section. In particular, if you are not a member of the French Speedcubing Association (see [here](https://www.speedcubingfrance.org/association/adhesion)) and if this is not your first competition, please make sure that you paid your registration fee. You could also be on the waiting list. The competitor limit can be found on the *[General info](#general-info)* page, and you can see the number of accepted competitors on the *[Competitors](https://www.worldcubeassociation.org/competitions/FMCFrance2023/registrations)*  page. If you have done everything correctly, paid if necessary and the competition is not full then just be patient. We have to manually approve registrations and the organisers aren't available all the time. If you believe you have followed the steps correctly but still are not on the registration list after 2 days, then feel free to email us at the *Contact* link on the *[General info](#general-info)* page.\r\n\r\n**Q: I am a member of the French Speedcubing Association or it is my first competition, and the page still asks me to pay. What should I do?**\r\n**A:** As mentioned on the competition page, no need to pay! The WCA website shows the payment page by default since it cannot know if your registration is free or not, but don’t worry : the organisation team knows who is a member and/or a first time competitor, they will control who need to pay and who doesn’t and will take that information into account when they approve registrations.\r\n\r\n**Q: Can I change the events I am registered for?**\r\n**A:** If the organisation team allowed it, you can edit your event list here until the end of the registration period. If it is not the case, you can send an email to the organisation team directly, through the *Contact* link on the *[General info](#general-info)* page.\r\n\r\n**Q: I am no longer able to attend, what should I do?**\r\n**A:** The first thing you need to do is tell us as soon as possible via the contact link on the *[General info](#general-info)* page. Competitions generally fill up quite quickly and letting us know that you can't attend means we can approve someone else’s registration. Your registration fee will be refunded if you contact us before the deadline indicated on the *[General info](#general-info)* page.\r\n\r\n**Q: How fast do I have to be to compete?**\r\n**A:** We recommend that you check out the *[Schedule](#competition-schedule)* tab - if you can make the time limit for the events you want to compete in, then you're fast enough! The events that are usually appreciated by beginners (3x3, 2x2, pyraminx, skewb) usually have a time limit of 10 minutes, which is usually enough for most competitors. Loads of people come to competitions just to beat their own personal bests, and meet likeminded people, with no intention of winning.\r\n\r\n**Q: Are there different age categories?**\r\n**A:** All competitors compete at the same level and all ages, genders, nationalities are welcome.\r\n\r\n**Q: Do I have to compete in all events?**\r\n**A:** No, there is a separate ranking for each event. You can choose the events you want to participate in. For this, you just need to select the correct images when you register. \r\n\r\n**Q: Do I use my own cubes to compete?**\r\n**A:** Yes! Make sure to bring cubes for all events you are competing in and look after them, you don't want them to go missing. Theft is rare but it is quite common to take a cube similar to your own, without paying attention. \r\nPlease make sure that your cube is allowed for the competition. Connected cubes or cubes with several logos are forbidden for official attempts. All logos are forbidden for blind events, even if it cannot be felt by touching it.\r\n\r\n**Q: Can I come only to spectate?**\r\n**A:** Yes! Unless indicated otherwise on the *[General info](#general-info)* page, spectating competitions is free for everyone. Take a look at the *[Schedule](#competition-schedule)* to be sure to attend events you are more interested in or to know when the finals are happening.\r\n\r\n**Q: When should I arrive at the competition?**\r\n**A:** If you are a new competitor, we highly recommend that you show up about 20 minutes before the tutorial (please look at the *[Schedule](#competition-schedule)* tab to check when it is planned). Otherwise, we recommend you turn up about 30 minutes before your first event. Please note that if you arrive after the end of an event you were registered to, you won’t be able to compete. \r\n\r\n**Q: What should I do when I arrive?**\r\n**A:** The first thing you should do when you arrive is find the registration desk and introduce yourself. If you are a new competitor, think of taking an ID (or any document mentioning your name, birthdate and nationality) because we will ask for it at registration. The people at registration desk will then be able to guide you and answer your first questions.\r\n\r\n**Q: When can I leave the competition?**\r\n**A:** It's only necessary to stay when you have to compete or be a judge/runner/scrambler (the organisers will probably provide you with an individual schedule at registration). Once you do not have any duty left, you are free to go. Think about checking the results before leaving : maybe you qualified for a subsequent round!\r\n\r\n**Q: How do I find results?**\r\n**A:** If you are looking for live results, they can all be found on *[WCA Live](https://live.worldcubeassociation.org/)* and available about half an hour after each round has been completed.\r\nAll the official results will be found on this page a couple of days after the competition, once they have all been checked and uploaded. \r\n\r\n**Q: How do I create my WCA ID?**\r\n**A:** The WCA IDs are created automatically after the publication of the results (less than a week after the end of the competition). The format is : Year of the first competition – 4 first letters of the surname – two numbers to differentiate people with the same information.\r\n\r\n**Q: I usually practice while listening to music. Can I use headphones or a headset during my official attempts?**\r\n**A:** No, headsets and headphones are forbidden during all official attemps and using them would disqualify the attempts where they have been used. If you use your headset as a way to be more focused or less stressed, you can use noise-cancelling headphones with no electronic component. \r\n\r\n**Q: Can I film my solves?**\r\n**A:** Yes you can, with a camera on a stand (gopro or any other kind), or a mobile phone. Careful : in case of a phone or a camera with a screen, the screen cannot be turned towards you. Once the solve starts (which means once the inspection has started), it is not allowed to touch your device anymore, even if it falls, or the solve will be disqualified (DNF).\r\n\r\n_________________\r\n\r\n###**[Esperanto]**\r\n\r\n**D: Kiel mi registriĝu?**\r\n**R:** Unue, vi devas krei konton en la retejo de la WCA. Vi povas fari tion alklakante *[Ensaluti](https://www.worldcubeassociation.org/users/sign_up)*. Post kiam vi kreis vian konton kaj konfirmis vian retadreson, iru al la langeto *[Registriĝi](https://www.worldcubeassociation.org/competitions/FMCFrance2023/register)* de la konkurso pri kiu vi interesiĝas, legu kaj sekvu la instrukciojn zorge.\r\n\r\n**D: Kial mi ne estas en la listo de konkursantoj**\r\n**R:** Bonvolu certigi, ke vi legis kaj sekvis la instrukciojn en la sekcio *[Registriĝi](https://www.worldcubeassociation.org/competitions/FMCFrance2023/register)* de la konkurso. Precipe, se vi ne estas AFS-membro (vidu [tie](https://www.speedcubingfrance.org/association/adhesion)), kaj se ĉi tio ne estas via unua konkurso, bonvolu kontroli, ke vi pagis por la konkurso.\r\nVi ankaŭ povas esti en la atendolisto. La maksimuma nombro de partoprenantoj troviĝas sur la ĉefpaĝo de la konkurso (langeto *[Ĝeneralaj informoj](#general-info)*) kaj vi povas vidi la nombron da homoj jam akceptitaj sur la paĝo *[Konkursantoj ](https://www.worldcubeassociation.org/competitions/FMCFrance2023/registrations)* de la konkurso. Se vi faris ĉion ĝuste, pagis se necese, kaj la konkurso ne estas plena, paciencu. Ni devas permane akcepti registriĝojn kaj organizaj teamoj ne estas disponeblaj ĉiam. Se vi pensas, ke vi faris ĉion ĝuste, sed vi ankoraŭ ne estas akceptita post du tagoj, tiam kontaktu nin alklakante la ligilon *Kontakto* ĉe la ĉefpaĝo de la konkurso, langeto *[Ĝenerala informo](#generalo-info)*.\r\n\r\n**D: Mi estas AFS-membro, aŭ ĉi tiu estas mia unua konkurso, kaj la retejo ankoraŭ petas min pagi, kion mi faru?**\r\n**R:** Kiel diras la konkurspaĝo, ne necesas pagi! La retejo de la WCA montras la pagpaĝon defaŭlte ĉar ĝi ne povas scii ĉu via registriĝo estas pagita de la AFS aŭ ne, sed, estu certa, la organiza teamo scios, kontrolos kiu devas pagi kaj kiu ne bezonas, kaj tial konsideru ĉi tiujn datumojn dum validado de registradoj.\r\nSe vi ne certas ĉu vi estas AFS-membro, kontrolu ensalutante al la retejo de la asocio kaj poste irante al via profilo.\r\n\r\n**D: Ĉu mi povas ŝanĝi la konkurserojn por kiuj mi registriĝis?**\r\n**R:** Se la organiza teamo permesis tion, vi povas ŝanĝi viajn konkurserojn ĉi tie ĝis la fino de la registriĝperiodo. Se tio ne eblas, vi povas kontakti la organizan teamon rekte per la ligilo *Kontakto* ĉe la langeto *[Ĝeneralaj informoj](#general-info)*.\r\n\r\n**D: Mi ne plu povas veni al la konkurso. Kion mi faru ?**\r\n**R:** Bonvolu sciigi nin tuj kiam vi scias, ke vi ne plu povas veni, sendante al ni retmesaĝon alklakante la ligilon *Kontakto* ĉe la ĉefpaĝo de la konkurso, langeto *[Ĝenerala Informo]( #general-info)*. Konkursoj kutime pleniĝas sufiĉe rapide kaj sciigi nin pri via malregistriĝo permesas al ni akcepti iun el la atendolisto. Via pago estos repagata se vi malregistriĝas antaŭ la dato skribita sur la paĝo *[Ĝenerala Informo](#general-info)*.\r\n\r\n**D: Ĉu mi devas esti tre rapida por povi partopreni?**\r\n**R:** Ni rekomendas rigardi la paĝon *[Horplano](#competition-schedule)* de la konkurso. Por ĉiu provo, se vi povas solvi la kubon pli rapide ol la tempo indikita en *Tempolimo*, vi estas sufiĉe rapida! La konkurseroj kiujn ĝenerale ŝatas komencantoj (3x3, 2x2, Pyraminx, Skewb) plejofte havas *Tempolimon* de 10 minutoj, kio lasas al granda plimulto de konkursantoj la ŝancon partopreni. Multaj homoj venas al konkurso kun la sola celo amuziĝi kaj plibonigi siajn proprajn rekordojn, sen pensi pri venkado.\r\n\r\n**D: Ĉu ekzistas malsamaj kategorioj?**\r\n**R:** Ĉiuj konkursantoj partoprenas kune kaj ĉiuj aĝoj, genroj, naciecoj estas akceptitaj en konkursoj.\r\n\r\n**D: Ĉu mi devas partopreni en ĉiujn konkurserojn?**\r\n**R:** Ne. Estas rangotabelo por ĉiu konkursero. Do vi povas partopreni nur en tiuj, kiujn vi ŝatas. Vi devos elekti la ĝustajn bildojn dum registrado.\r\n\r\n**D: Ĉu mi devas uzi miajn proprajn kubojn por partopreni?**\r\n**R:** Jes! Certigu, ke vi kunportu almenaŭ unu kubon por ĉiu konkursero al kiu vi registriĝis kaj atentu ilin dum la konkurso. Ŝteloj estas tre maloftaj sed kutimas preni kubon similan al via sen atenti ĝin.\r\nCertiĝu, tamen, ke via kubo estas rajtigita. Konektitaj kuboj aŭ kuboj kun pluraj emblemoj estas malpermesataj por oficialaj provoj. Ankaŭ notu, ke iu ajn kubo kun emblemo (eĉ se ekzistas nur unu kaj ne povas esti \\'sentita per tuŝo\\') estas malpermesita por blindaj konkurseroj.\r\n\r\n**D: Ĉu mi povas veni nur kiel spektanto?**\r\n**R:** Jes, krom se alie specifita en la Ĝenerala Informo de la konkurso, la konkursoj estas alireblaj senpage. Vi povas rigardi la langeton *[Horplano](#competition-schedule)* por vidi la horarojn por la konkurseroj kiuj interesas vin.\r\n\r\n**D: Je kioma horo mi alvenu por la konkurso?**\r\n**R:** Se ĉi tio estas via unua konkurso, ni konsilas al vi rigardi la *[Horplano](#competition-schedule)* por scii kiam okazos la lernotempo, kaj alveni ĉirkaŭ 20 minutojn antaŭe. Se ne, bonvolu alveni al la konkurso proksimume 30 minutojn antaŭ la komenco de via unua konkursero. Bonvolu noti, ke se vi alvenos post la fino de unu el viaj konkurseroj, ni ne povos lasi vin partopreni por tiu ĉi.\r\n\r\n**D: Kion mi faru kiam mi alvenos al la konkurso?**\r\n**R:** La unua afero estas trovi la akceptejon kaj prezenti vin. Se vi estas nova konkursanto, memoru kunporti identan dokumenton (aŭ ajnan dokumenton menciantan vian nomon, antaŭnomon kaj naskiĝdaton) ĉar ĝi estos petita de vi ĉe la akceptejo. La persono, kiu bonvenigos vin, povas tiam gvidi vin kaj respondi viajn unuajn demandojn.\r\n\r\n**D: Kiam mi povas forlasi la konkurson?**\r\n**R:** Necesas nur ĉeesti kiam vi devas partopreni aŭ juĝi/kuri/miksi (individua horplano verŝajne estos donita al vi ĉe la enirejo de la konkurso). Post kiam vi ne plu havas taskojn, vi rajtas foriri. Memoru kontroli ĉu vi kvalifikiĝis por alia rondo, vi neniam scias!\r\n\r\n**D: Kie mi povas trovi la rezultojn?**\r\n**R:** Dum la konkurso, rezultoj estas enmetitaj permane en *[WCA Live](https://live.worldcubeassociation.org/)* kaj disponeblas interrete proksimume duonhoron post la fino de ĉiu raŭndo.\r\nJe la fino de la konkurso, ĉiuj rezultoj estos disponeblaj sur ĉi tiu paĝo.\r\n\r\n**D: Kiel krei mian WCA-ID?**\r\n**R:** WCA-ID estas kreitaj aŭtomate tuj kiam la rezultoj estas publikigitaj (malpli ol semajnon post la fino de la konkurso). La formato estas: Jaro de la unua konkurso – unuaj 4 literoj de la familia nomo – du ciferoj uzataj por diferencigi homojn, kiuj havas la samajn informojn.\r\n\r\n**D: Mi kutime trejnas aŭskultante muzikon. Ĉu mi povas uzi kapaŭskultilo dum miaj oficialaj provoj?**\r\n**R:** Kapaŭskultiloj estas strikte malpermesitaj dum la oficialaj testoj, ilia uzo do kondukus al malkvalifiko de la koncernaj provoj. Se la kapaŭskultilo helpas vin esti pli koncentrita aŭ malpli streĉita, tiam vi povas uzi bru-nuligantajn kapaĵojn nur kondiĉe, ke ili estas sen elektronikaj komponantoj.\r\n\r\n**D: Ĉu mi povas filmi miajn solvojn?**\r\n**R:** Tute eblas, per fotilo kun piedo (gopro aŭ alia) aŭ poŝtelefono. Atentu tamen: se vi uzas poŝtelefonon aŭ aparaton kun ekrano, ĝi ne devas esti direktita al vi. Post kiam la solvo komenciĝas, tio estas tuj kiam la inspektado komenciĝis, estas strikte malpermesata tuŝi vian fotilon, eĉ se ĝi falas, sub puno de malkvalifiko de la solvo (DNF).",
            display_order: 3,
          },
          {
            id: 34418,
            competition_id: 'FMCFrance2023',
            name: 'AFS',
            content:
              "###**ASSOCIATION FRANÇAISE DE SPEEDCUBING**\r\n\r\n**[Français]** L'[Association Française de Speedcubing](https://www.speedcubingfrance.org) est une association loi 1901, regroupant des bénévoles et membres passionné·e·s autour de la pratique des casse-tête rotatifs, dont le cube inventé par Ernö Rubik est le plus célèbre représentant. Elle a pour but de promouvoir la discipline, notamment en facilitant l'organisation sur le territoire français de compétitions officielles. À ce titre, elle soutient l'organisation de la compétition en mettant son matériel, son assurance et/ou un financement à disposition !\r\n**[English]** The [French Speedcubing Association (AFS)](https://www.speedcubingfrance.org) is a legal association of 1901, bringing together volunteers and passionate members around the practice of rotary puzzles, whose cube invented by Ernö Rubik is the most famous representative. Its purpose is to promote the discipline, notably by facilitating the organization of official competitions on French territory. As such, it supports the organization of the competition by making its equipment, insurance and/or financing available!\r\n**[Esperanto]** La [Franca Asocio de Rapidkubumado](https://www.speedcubingfrance.org) estas asocio leĝo 1901, kunigante volontulojn kaj membrojn pasiajn pri la praktiko de \"twisty puzzles\" (~ turnantaj puzloj), el kiuj la kubo inventita de Ernő Rubik estas la plej fama reprezentanto. Ĝia celo estas antaŭenigi tiun disciplinon, precipe faciligante la organizadon de oficialaj konkursoj sur franca teritorio. Kiel tia, ĝi subtenas la organizon de la konkurso disponigante sian ekipaĵon, asekuron kaj/aŭ financadon!\r\n**[Galo]** La [Souéte Françaeze de Speedcubing](https://www.speedcubingfrance.org) ét ene souéte louai 1901, qhi ramoucele des benvoulant·e·s e des souétou·ère·s ataïnë·ée·s a la fezerie de \"bezaignes ournissants qhi tournent\" (\"twisty puzzles\"), de cai le qhube inventë o Ernő Rubik ét le pûs de la qenûe. Son but ét de parlever le demaine-la, surtout en rendant pûs ézë de mener des courses aqenûes su le payiz françaez. Pour ela, o parleve la menerie de la course-li o mettant d'amain ses oûtis, son assûrance e/ou son arjent!\r\n**[Brezhoneg]** Ur gevredigezh lezenn 1901 eo [Kevredigezh Bro-C'hall Speedcubing](https://www.speedcubingfrance.org). Strollañ a ra tud youl-vat ha tud entanet gant pleustr c'hoarioù troiat (\"twisty puzzles\"), m'eo an hini brudañ an diñs ijinet gant Ernő Rubik. Kas war-raok an diskiblezh eo he fal, da skouer en ur aesañ aozadur kenstrivadegoù ofisiel war tiriad Bro-C'hall. Setu perak eo harpet ar kenstrivadeg gant an AFS en ur lakaat hegerz he periant, he asurañs hag/pe he arc'hant!\r\n**[Occitan]** L'[Associacion Francesa d'Speedcubing](https://www.speedcubingfrance.org) retòrna aquela competicion possibla en metent son material a nòstra disposicion!\r\n**[Euskara]**\r\n**[Arpetan]** L'[Associacion Francêsa de Speedcubing](https://www.speedcubingfrance.org) rebalye ceta compèticion possibla en metent son matèrièl a noutra disposicion !\r\n\r\n![](https://www.worldcubeassociation.org/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBbDBkIiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--5aef587ee5a18782417e5b645a5c4d1bb3d40843/logoafsletters.png)",
            display_order: 4,
          },
          {
            id: 34421,
            competition_id: 'FMCFrance2023',
            name: 'Résultats en direct | Live results',
            content:
              "**[Français]** Les résultats de la compétition en (presque) direct sont disponibles sur [WCA Live](https://live.worldcubeassociation.org).\r\n**[English]** Live results of the competition are available on [WCA Live](https://live.worldcubeassociation.org).\r\n**[Esperanto]** (Pli malpli) realtempaj rezultoj de la konkurso haveblas ĉe [WCA Live](https://live.worldcubeassociation.org).\r\n**[Galo]** Vous pouéz sieudr les fezûres de la course-la (presqement) en dret su [WCA Live](https://live.worldcubeassociation.org).\r\n**[Brezhoneg]** Gallout a rit heuliañ an disoc'hioù kazi war-eeun war [WCA Live](https://live.worldcubeassociation.org).\r\n**[Occitan (gascon)]** Los resultats de la competicion en (quasi) dirècte que son disponibles sus [WCA Live](https://live.worldcubeassociation.org).\r\n**[Euskara]** Txapelketa honetako (ia) zuzeneko emaitzak [WCA Live-n](https://live.worldcubeassociation.org) aurki ditzakezue.",
            display_order: 5,
          },
        ],
        'class': 'competition',
      }
    when "RheinNeckarAutumn2023"
      {
        'id': 'RheinNeckarAutumn2023',
        'name': 'Rhein-Neckar Autumn 2023',
        'information': '',
        'venue': 'Sonnbergschule',
        'contact': 'rheinneckarorga@gmail.com',
        'registration_open': self.date_from_now(-1),
        'registration_close': self.date_from_now(1),
        'use_wca_registration': true,
        'announced_at': '2023-07-30T11:14:17.000Z',
        'base_entry_fee_lowest_denomination': 1000,
        'currency_code': 'EUR',
        'start_date': self.date_from_now(1, 1),
        'end_date': self.date_from_now(1, 1),
        'enable_donations': false,
        'competitor_limit': 150,
        'extra_registration_requirements':
          "### Deutsch:\r\n**1. Erstelle einen WCA-Account**\r\n(Dieser Schritt gilt NUR für Newcomer und Teilnehmer ohne WCA-Account): Erstelle [hier](https://www.worldcubeassociation.org/users/sign_up) einen WCA-Account.\r\n**2. Fülle das Anmeldeformular aus**\r\nFülle das Anmeldeformular aus und schicke es ab: [klicke hier und scrolle ganz nach unten](https://www.worldcubeassociation.org/competitions/RheinNeckarAutumn2023/register).\r\n**3. Zahle die Anmeldegebühr**\r\nDie Anmeldegebühr beträgt 10€ und kann über PayPal [*über diesen Link*](https://www.paypal.com/paypalme/alexanderbotz/10) (https://www.paypal.com/paypalme/alexanderbotz/10) gezahlt werden.\r\n\r\nOhne Zahlung ist die Anmeldung nicht vollständig! Falls der Name bei der Zahlung und der Name im Anmeldeformular nicht identisch sind, gib bitte den Namen des Teilnehmers im Anmeldeformular im letzten Schritt der Zahlungsprozedur an. *Eine Zahlung gilt erst dann als geleistet, wenn wir diese eindeutig zuordnen können.* \r\nFalls du keinen Zugang zu PayPal besitzt, kontaktiere bitte die Organisatoren unter rheinneckarorga@gmail.com\r\nWenn das Teilnehmerlimit bereits erreicht wurde, erhältst du einen Platz auf der Warteliste. Danach erhältst du eine E-Mail, sobald ein Platz für dich frei werden sollte. \r\nFalls du keinen freien Teilnehmerplatz mehr erlangen solltest, wird die Anmeldegebühr selbstverständlich erstattet .\r\n\r\n\r\n### English:\r\n**1. Create a WCA account**.\r\n(This step ONLY applies to newcomers and participants without a WCA account): Create a WCA account [here](https://www.worldcubeassociation.org/users/sign_up).\r\n**2. Fill out the registration form**.\r\nFill in the registration form and submit it: [click here and scroll all the way down](https://www.worldcubeassociation.org/competitions/RheinNeckarAutumn2023/register).\r\n**3. Pay the registration fee**\r\nPlease pay the registration fee (10€ per competitor) [*via this link*](https://www.paypal.com/paypalme/alexanderbotz/10) (https://www.paypal.com/paypalme/alexanderbotz/10). \r\n\r\nThe registration is not completed until the money is paid! If the name on the payment and the name on the registration form are not identical, please enter the name of the participant on the registration form in the last step of the payment procedure. *A payment is only considered to have been made when we can clearly allocate it.*\r\nIf you have no access to PayPal, please contact the organization team via rheinneckarorga@gmail.com\r\nIf you have registered and the competitor limit has been reached, you will receive a spot on the waiting list. You will be notified via E-Mail once a spot for you frees up. \r\nIf you don't obtain a free spot until registration closes, you will get a full refund.\r\n",
        'on_the_spot_registration': false,
        'on_the_spot_entry_fee_lowest_denomination': nil,
        'refund_policy_percent': 100,
        'refund_policy_limit_date': self.date_from_now(1),
        'guests_entry_fee_lowest_denomination': 0,
        'qualification_results': false,
        'external_registration_page': '',
        'event_restrictions': false,
        'cancelled_at': nil,
        'waiting_list_deadline_date': self.date_from_now(1),
        'event_change_deadline_date': nil,
        'guest_entry_status': 'free',
        'allow_registration_edits': true,
        'allow_registration_self_delete_after_acceptance': false,
        'allow_registration_without_qualification': false,
        'guests_per_registration_limit': nil,
        'force_comment_in_registration': false,
        'url':
          'https://www.worldcubeassociation.org/competitions/RheinNeckarAutumn2023',
        'website':
          'https://www.worldcubeassociation.org/competitions/RheinNeckarAutumn2023',
        'short_name': 'Rhein-Neckar Autumn 2023',
        'city': 'Laudenbach',
        'venue_address': 'Schillerstraße 6, 69514 Laudenbach, Deutschland',
        'venue_details':
          'On the first floor in the back, reachable through a metal staircase at the outside of the building.',
        'latitude_degrees': 49.61296,
        'longitude_degrees': 8.6508,
        'country_iso2': 'DE',
        'event_ids': %w[333 444 555 666 777 333bf 333oh clock minx skewb sq1],
        'registration_opened?': true,
        'main_event_id': '333',
        'number_of_bookmarks': 102,
        'using_stripe_payments?': true,
        'uses_qualification?': false,
        'uses_cutoff?': true,
        'delegates': [
          {
            id: 49811,
            created_at: '2017-03-12T14:12:46.000Z',
            updated_at: '2023-10-30T07:51:41.000Z',
            name: 'Laura Holzhauer',
            delegate_status: 'delegate',
            wca_id: '2016HOLZ01',
            gender: 'f',
            country_iso2: 'DE',
            url: 'https://www.worldcubeassociation.org/persons/2016HOLZ01',
            country: {
              id: 'Germany',
              name: 'Germany',
              continentId: '_Europe',
              iso2: 'DE',
            },
            email: 'lholzhauer@worldcubeassociation.org',
            location: 'Germany',
            senior_delegate_id: 454,
            class: 'user',
            teams: [],
            avatar: {
              url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2016HOLZ01/1641847100.jpg',
              pending_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              thumb_url:
                'https://avatars.worldcubeassociation.org/uploads/user/avatar/2016HOLZ01/1641847100_thumb.jpg',
              is_default: false,
            },
          },
          {
            id: 51037,
            created_at: '2017-03-20T21:02:21.000Z',
            updated_at: '2023-10-30T18:26:47.000Z',
            name: 'Ricardo Olea Catalán',
            delegate_status: 'candidate_delegate',
            wca_id: '2017CATA04',
            gender: 'm',
            country_iso2: 'DE',
            url: 'https://www.worldcubeassociation.org/persons/2017CATA04',
            country: {
              id: 'Germany',
              name: 'Germany',
              continentId: '_Europe',
              iso2: 'DE',
            },
            email: 'rcatalan@worldcubeassociation.org',
            location: 'Germany',
            senior_delegate_id: 454,
            class: 'user',
            teams: [],
            avatar: {
              url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2017CATA04/1570127985.jpg',
              pending_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              thumb_url:
                'https://avatars.worldcubeassociation.org/uploads/user/avatar/2017CATA04/1570127985_thumb.jpg',
              is_default: false,
            },
          },
        ],
        'organizers': [
          {
            id: 7063,
            created_at: '2015-12-16T15:08:20.000Z',
            updated_at: '2023-10-01T18:57:39.000Z',
            name: 'Alexander Botz',
            delegate_status: nil,
            wca_id: '2013BOTZ01',
            gender: 'm',
            country_iso2: 'DE',
            url: 'https://www.worldcubeassociation.org/persons/2013BOTZ01',
            country: {
              id: 'Germany',
              name: 'Germany',
              continentId: '_Europe',
              iso2: 'DE',
            },
            class: 'user',
            teams: [],
            avatar: {
              url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2013BOTZ01/1674179228.jpeg',
              pending_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              thumb_url:
                'https://avatars.worldcubeassociation.org/uploads/user/avatar/2013BOTZ01/1674179228_thumb.jpeg',
              is_default: false,
            },
          },
          {
            id: 7943,
            created_at: '2016-01-10T21:03:25.000Z',
            updated_at: '2023-10-25T08:15:05.000Z',
            name: 'Wilhelm Kilders',
            delegate_status: nil,
            wca_id: '2010KILD02',
            gender: 'm',
            country_iso2: 'DE',
            url: 'https://www.worldcubeassociation.org/persons/2010KILD02',
            country: {
              id: 'Germany',
              name: 'Germany',
              continentId: '_Europe',
              iso2: 'DE',
            },
            class: 'user',
            teams: [],
            avatar: {
              url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2010KILD02/1692273854.jpg',
              pending_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              thumb_url:
                'https://avatars.worldcubeassociation.org/uploads/user/avatar/2010KILD02/1692273854_thumb.jpg',
              is_default: false,
            },
          },
          {
            id: 14457,
            created_at: '2016-03-15T12:20:45.000Z',
            updated_at: '2023-09-22T18:05:10.000Z',
            name: 'Christian König',
            delegate_status: nil,
            wca_id: '2015KOEN01',
            gender: 'm',
            country_iso2: 'DE',
            url: 'https://www.worldcubeassociation.org/persons/2015KOEN01',
            country: {
              id: 'Germany',
              name: 'Germany',
              continentId: '_Europe',
              iso2: 'DE',
            },
            class: 'user',
            teams: [],
            avatar: {
              url: 'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              pending_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              thumb_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              is_default: true,
            },
          },
          {
            id: 14969,
            created_at: '2016-03-22T00:43:40.000Z',
            updated_at: '2023-10-24T07:14:18.000Z',
            name: 'Malte Ihlefeld',
            delegate_status: nil,
            wca_id: '2016IHLE01',
            gender: 'm',
            country_iso2: 'DE',
            url: 'https://www.worldcubeassociation.org/persons/2016IHLE01',
            country: {
              id: 'Germany',
              name: 'Germany',
              continentId: '_Europe',
              iso2: 'DE',
            },
            class: 'user',
            teams: [],
            avatar: {
              url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2016IHLE01/1658481357.jpg',
              pending_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              thumb_url:
                'https://avatars.worldcubeassociation.org/uploads/user/avatar/2016IHLE01/1658481357_thumb.jpg',
              is_default: false,
            },
          },
          {
            id: 49811,
            created_at: '2017-03-12T14:12:46.000Z',
            updated_at: '2023-10-30T07:51:41.000Z',
            name: 'Laura Holzhauer',
            delegate_status: 'delegate',
            wca_id: '2016HOLZ01',
            gender: 'f',
            country_iso2: 'DE',
            url: 'https://www.worldcubeassociation.org/persons/2016HOLZ01',
            country: {
              id: 'Germany',
              name: 'Germany',
              continentId: '_Europe',
              iso2: 'DE',
            },
            email: 'lholzhauer@worldcubeassociation.org',
            location: 'Germany',
            senior_delegate_id: 454,
            class: 'user',
            teams: [],
            avatar: {
              url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2016HOLZ01/1641847100.jpg',
              pending_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              thumb_url:
                'https://avatars.worldcubeassociation.org/uploads/user/avatar/2016HOLZ01/1641847100_thumb.jpg',
              is_default: false,
            },
          },
          {
            id: 53959,
            created_at: '2017-04-13T19:12:35.000Z',
            updated_at: '2023-10-29T23:41:11.000Z',
            name: 'Luis Kleinheinz',
            delegate_status: nil,
            wca_id: '2017KLEI02',
            gender: 'm',
            country_iso2: 'DE',
            url: 'https://www.worldcubeassociation.org/persons/2017KLEI02',
            country: {
              id: 'Germany',
              name: 'Germany',
              continentId: '_Europe',
              iso2: 'DE',
            },
            class: 'user',
            teams: [],
            avatar: {
              url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2017KLEI02/1653555632.jpeg',
              pending_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              thumb_url:
                'https://avatars.worldcubeassociation.org/uploads/user/avatar/2017KLEI02/1653555632_thumb.jpeg',
              is_default: false,
            },
          },
          {
            id: 110227,
            created_at: '2018-05-22T15:59:22.000Z',
            updated_at: '2023-10-23T14:24:01.000Z',
            name: 'Melda Eksi',
            delegate_status: nil,
            wca_id: '2013EKSI01',
            gender: 'f',
            country_iso2: 'DE',
            url: 'https://www.worldcubeassociation.org/persons/2013EKSI01',
            country: {
              id: 'Germany',
              name: 'Germany',
              continentId: '_Europe',
              iso2: 'DE',
            },
            class: 'user',
            teams: [],
            avatar: {
              url: 'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              pending_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              thumb_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              is_default: true,
            },
          },
          {
            id: 245022,
            created_at: '2021-11-01T13:43:57.000Z',
            updated_at: '2023-10-30T23:00:59.000Z',
            name: 'Johanna Szczesny',
            delegate_status: nil,
            wca_id: '2022SZCZ03',
            gender: 'f',
            country_iso2: 'DE',
            url: 'https://www.worldcubeassociation.org/persons/2022SZCZ03',
            country: {
              id: 'Germany',
              name: 'Germany',
              continentId: '_Europe',
              iso2: 'DE',
            },
            class: 'user',
            teams: [],
            avatar: {
              url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2022SZCZ03/1674379919.jpg',
              pending_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              thumb_url:
                'https://avatars.worldcubeassociation.org/uploads/user/avatar/2022SZCZ03/1674379919_thumb.jpg',
              is_default: false,
            },
          },
        ],
        'tabs': [
          {
            id: 30361,
            competition_id: 'RheinNeckarAutumn2023',
            name: 'Newcomers \u0026 Results / Neulinge \u0026 Ergebnisse',
            content:
              "#Deutsch\r\n\r\n##Informationen für Neulinge\r\nFalls dies dein erstes WCA Turnier sein sollte, beachte bitte die folgenden Punkte:\r\n\r\n* Alle Neulinge sind dazu verpflichtet ein **Ausweisdokument** an der Anmeldung vor zu zeigen (Regulation [2e)](https://www.worldcubeassociation.org/regulations/#2e)). Aus dem Dokument müssen Name, Nationalität und Geburtsdatum hervorgehen.\r\n\r\n* Alle Neulinge sind eindringlich gebeten, am **Tutorial** (siehe Zeitplan) teilzunehmen.\r\n\r\n* Jeder Teilnehmer sollte bereits vor der Meisterschaft mindestens einmal die **[offiziellen Regeln der WCA](https://www.worldcubeassociation.org/regulations/translations/german/)** gelesen haben. Zusätzlich ist ein Blick in unsere [Teilnehmer-Anleitung](http://cube.hackvalue.de/tutorials/) sowie das [WCA Competition Tutorial](https://www.worldcubeassociation.org/files/WCA_Competition_Tutorial.pdf) mehr als ratsam für alle Neulinge!\r\n* Keine Angst: während des Turniers besteht die Möglichkeit, sich mit dem offiziellen Equipment (Stackmat-Timer) vertraut zu machen und Fragen zu stellen. \r\n* Bei wichtigen Fragen vor dem Turnier kannst du dich gerne [an das Organisationsteam wenden](mailto:rheinneckaropen@gmail.com).\r\n\r\nLive Ergebnisse werden hier veröffentlicht: https://live.worldcubeassociation.org/\r\nNach dem Wettkampf werden alle Ergebnisse in die Datenbank der WCA hochgeladen, und auf dieser Seite einzusehen sein.\r\n\r\n#English\r\n\r\n##Newcomer information\r\nIf this is your first WCA competition, please pay attention to the following:\r\n\r\n* According to Regulation [2e)](https://www.worldcubeassociation.org/regulations/#2e), all newcomers are required to bring some form of **identification document**  that shows name, citizenship and date of birth.\r\n\r\n* All newcomers are urgently asked to attend the **Tutorial** (see schedule). \r\n* Every competitor should have read the [**official WCA regulations**](https://www.worldcubeassociation.org/regulations) at least once before attending the competition! A more condensed version of the important regulations can be found at the [WCA Competition Tutorial](https://www.worldcubeassociation.org/files/WCA_Competition_Tutorial.pdf).\r\n* Don't be afraid: there will also be time to test the equipment (for example the official timing device, the Stackmat timer) and discuss the rules if you have questions at the competition. \r\n* Feel free to [contact the organizer](mailto:rheinneckaropen@gmail.com) if you have any uncertainties.\r\n\r\nLive results will be available here: https://live.worldcubeassociation.org/\r\nAll results will be uploaded to the WCA database after the competition, and will be available right here!\r\n\r\n\r\n\r\n",
            display_order: 1,
          },
          {
            id: 30363,
            competition_id: 'RheinNeckarAutumn2023',
            name: 'Foto- und Videoaufnahmen / Photo and video recordings',
            content:
              "# Deutsch\r\nAuf der Veranstaltung können eventuell **Foto- und Videoaufnahmen**  gemacht werden. Alle Fotos und Videos werden nach der Veranstaltung den Teilnehmerinnen und Teilnehmern zur Verfügung gestellt. \r\n\r\n**Einverständnis**: Mit deiner Anmeldung erklärst du dich damit einverstanden, dass Fotos oder Videos von dir später veröffentlicht werden können. Gleiches gilt für Gäste, die Teilnehmer begleiten oder generell zuschauen.\r\n**Unter 18 Jahre alt?** Bitte hol dir dein Einverständnis deiner Eltern dazu.\r\n\r\n**Bedenken**: Sofern du hierzu Bedenken haben solltest oder nicht einverstanden bist, kontaktiere uns bitte [hier](mailto:rheinneckarorga@gmail.com), damit wir das entsprechend berücksichtigen können. Selbstverständlich kannst du dich trotzdem direkt anmelden.\r\n\r\n\r\n# English\r\n**Photography and video recordings** may be taken at the event. All photos and videos will be made available to participants after the event. The same applies to guests accompanying participants or watching in general.\r\n\r\n**Consent**: With your registration you agree that photos or videos of you may be published later. \r\n**Under 18 years old?** Please get your parents' consent for this.\r\n\r\n**Concerns**: If you have any concerns about this or do not agree, please contact us [here](mailto:rheinneckarorga@gmail.com) so that we can consider this accordingly. Of course you can still sign up directly.\r\n",
            display_order: 2,
          },
          {
            id: 30364,
            competition_id: 'RheinNeckarAutumn2023',
            name: 'Travel \u0026 Accommodation / Anreise \u0026 Unterkunft',
            content:
              "#Deutsch\r\n\r\nZur Haltestelle **Laudenbach (Bergstr.)** fährt die RB 68 (Richtung Frankfurt) stündlich von Heidelberg über **Laudenbach (Bergstr.)** nach Frankfurt. Von der Haltestelle aus sind es ca. 700 Meter zur Venue (über Schillerstraße).\r\nParkplätze sind auf dem Gelände vorhanden.\r\n\r\nIn Laudenbach und Umgebung gibt es einige Hotels, z.B.:\r\n\r\n* [Hotel am Bruchsee](https://www.tripadvisor.de/Hotel_Review-g227650-d228399-Reviews-Hotel_am_Bruchsee-Heppenheim_Hesse.html)\r\n* [Michel Hotel Heppenheim](https://www.tripadvisor.de/Hotel_Review-g227650-d233680-Reviews-Michel_Hotel_Heppenheim-Heppenheim_Hesse.html)\r\n* [Hotel-Restaurant Goldener Engel](https://www.tripadvisor.de/Hotel_Review-g227650-d1148536-Reviews-Hotel_Restaurant_Goldener_Engel-Heppenheim_Hesse.html)\r\n\r\n\r\n\r\n\r\n#English\r\nYou can take the line RB 68 from Heidelberg over **Laudenbach (Bergstr.)** to Frankfurt every hour. It's approximately a 700m walk from the station **Laudenbach (Bergstr.)** to the venue (over Schillerstraße).\r\nThere are parking options at the venue.\r\n\r\nThere are several hotels near the venue, for example:\r\n\r\n*   [Hotel am Bruchsee](https://www.tripadvisor.de/Hotel_Review-g227650-d228399-Reviews-Hotel_am_Bruchsee-Heppenheim_Hesse.html) \r\n* [Michel Hotel Heppenheim](https://www.tripadvisor.de/Hotel_Review-g227650-d233680-Reviews-Michel_Hotel_Heppenheim-Heppenheim_Hesse.html)\r\n* [Hotel-Restaurant Goldener Engel](https://www.tripadvisor.de/Hotel_Review-g227650-d1148536-Reviews-Hotel_Restaurant_Goldener_Engel-Heppenheim_Hesse.html)\r\n",
            display_order: 3,
          },
          {
            id: 30365,
            competition_id: 'RheinNeckarAutumn2023',
            name: 'Sponsor - Cuboss.com',
            content:
              '[![](https://cuboss.se/wp-content/uploads/2022/10/logo_400.png)](https://cuboss.com/?r=wca)\r\n​\r\n# ENGLISH\r\nRhein-Neckar Autumn 2023 will be sponsored by the cube store **[Cuboss.com](https://cuboss.com/?r=wca)**! Cuboss is an online cube store based in Sweden, specializing in speedcubes and other types of puzzles, with worldwide delivery available. Cuboss is sponsoring the competition with gift cards. Before the lunch break on Sunday (12:40 PM) we will give away ten **25€ voucher cards**, including five among all participants and five among all new participants. Furthermore we will give away another five **25€ voucher cards** for special achievements before the award ceremony.\r\n​\r\n​\r\n# GERMAN\r\nRhein-Neckar Autumn 2023 wird dieses Jahr von dem Würfelshop **[Cuboss.com](https://cuboss.com/?r=wca)** gesponsort! Cuboss ist ein Online-Würfeshop aus Schweden, der sich auf Speedcubes und Würfel aller Art spezialisiert hat, mit weltweitem Versand. Cuboss sponsort unseren Wettbewerb mit Gutscheinkarten. Vor der Mittagspause am Sonntag, also um 12:40 Uhr, werden wir zehn **25€ Gutscheinkarten verlosen**, darunter fünf unter allen Teilnehmern und fünf unter allen neuen Teilnehmern. Weitere fünf **25€ Gutscheinkarten** werden wir vor der Siegerehrung für spezielle Errungenschaften vergeben.',
            display_order: 4,
          },
          {
            id: 30366,
            competition_id: 'RheinNeckarAutumn2023',
            name: 'GCA',
            content:
              '[![](https://www.worldcubeassociation.org/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBcGNqIiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--3f93d32973ed5f3ad112f6e04ddc042b289f871c/Ohne%20Titel.jpg)](https://www.germancubeassociation.de/)\r\n\r\nAlle Wettkämpfe in Deutschland werden von Mitgliedern der [German Cube Association](https://www.germancubeassociation.de/) und weiteren freiwilligen Organisatoren aus dem ganzen Land durchgeführt. Bitte kommt auf uns zu, wenn auch ihr Interesse am Organisieren eines Turniers habt. Ihr könnt der German Cube Association e.V. auch als Mitglied beitreten! Weitere Informationen erhaltet ihr auf unserer Website.\r\nAll competitions in Germany are run by members of the [German Cube Association](https://www.germancubeassociation.de/) and further voluntary organisers from all over the country. Please approach us if you are interested in hosting a competition. You can also join the German Cube Association e.V. as a member! Further information is available on our website.\r\n\r\nFolge uns auf unseren Social-Media-Seiten, um über die neuesten Inhalte und Ankündigungen auf dem Laufenden zu bleiben!\r\nFollow us on social media to stay up to date with new information and announcements!\r\n\r\n[![](https://www.worldcubeassociation.org/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBcEVqIiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--c465d8deba5509ea829e38813e375c7a7b846b3f/fFmmADt.png)](https://www.instagram.com/germancubeassociation/) [![](https://www.worldcubeassociation.org/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBcFVqIiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--500c3d9550cb8161085be58845afbf73b50190e7/Bildschirmfoto%202022-09-25%20um%2012.08.41.png)](https://www.twitch.tv/germanonlinecubing2020/)',
            display_order: 5,
          },
          {
            id: 30367,
            competition_id: 'RheinNeckarAutumn2023',
            name: 'Verpflegung/Food\u0026Drinks',
            content:
              '#### Deutsch\r\nWährend des Wettbewerbs stellen wir euch gratis Getränke und kleine Snacks zur Verfügung.\r\n\r\n#### English\r\nAt the competition we offer free drinks and small snacks for all competitors.',
            display_order: 6,
          },
          {
            id: 34642,
            competition_id: 'RheinNeckarAutumn2023',
            name: 'Warteliste/ Waiting list',
            content:
              'Die Warteliste wird manuell aktualisiert. Deshalb kann es nach vollständiger Anmeldung (=Anmeldung+Zahlung der Teilnahmegebühr) etwas dauern, bis dein Name auf der Liste auftaucht.\r\nThe waiting list is updated manually. It might take a while until your name appears on the list after you have completed your registration (=registered and paid the fee).\r\n\r\n1. Andrina Löhle\r\n2. Raylan Prawinantomo\r\n3. Christian Blatz\r\n4. Klara Maria van Aerssen\r\n5. Daniel Förster\r\n6. Maximilian Wetzel',
            display_order: 7,
          },
        ],
        'class': 'competition',
      }
    when "HessenOpen2023"
      {
        'id': 'HessenOpen2023',
        'name': 'Hessen Open 2023',
        'information':
          'Hessen Open 2023 ist eine Zwei-Tages-Competition und Partner-Competition von Hessen Mini Open 2023, die am gleichen Wochenende stattfinden wird. Bitte beachte, dass du nur an einem der beiden Wettbewerbe teilnehmen kannst. Wenn du dich für beide Wettbewerbe anmeldest, so zählt nur die erste Anmeldung und wir werden die zweite (spätere) Anmeldung unverzüglich löschen.\r\n\r\nHessen Open 2023 is open to every citizen from every nation. Hessen Open 2023 is a two-day competition and series competition to Hessen Mini Open 2023, which will be held at the same weekend. Please note that you can only compete in one of the two competitions. If you register for both competitions, only the first registration will be valid and we will immediately delete the second (later) registration.',
        'venue': 'Bürgerhaus Hofheim',
        'contact': '[Orga-Team](mailto:Hessen-Open@gmx.de)',
        'registration_open': '2023-02-25T18:00:00.000Z',
        'registration_close': '2023-05-13T18:00:00.000Z',
        'use_wca_registration': true,
        'announced_at': '2023-02-16T17:38:45.000Z',
        'base_entry_fee_lowest_denomination': 500,
        'currency_code': 'EUR',
        'start_date': '2023-05-20',
        'end_date': '2023-05-21',
        'enable_donations': false,
        'competitor_limit': 90,
        'extra_registration_requirements':
          "#Deutsch:\r\n\\[1) Dieser Schritt gilt NUR für **Newcomer und Teilnehmer ohne WCA-Account**: [Erstellung eines WCA-Accounts](https://www.worldcubeassociation.org/users/sign_up)]\r\n2) Anmeldung für den Wettbewerb über das [Anmeldeformular](https://www.worldcubeassociation.org/competitions/HessenOpen2023/register).\r\n3) **Zahlung** des erforderlichen Betrags (**5€** pro Teilnehmer) per Paypal [*über diesen Link hier*](https://PayPal.Me/HO2023).  Bitte aktiviere **nicht** den optionalen Käuferschutz, da hierfür eine Gebühr vom gezahlten Eintrittspreis abgezogen wird. Gib bitte den Namen des Teilnehmers im letzten Schritt der Zahlungsprozedur an. Wir können Anmeldungen nicht bestätigen, wenn wir nicht eindeutig eine Zahlung zuordnen können.\r\n**Ohne Zahlung ist die Anmeldung nicht vollständig und wird nicht bestätigt.** Falls du keinen Zugang zu PayPal besitzt, kontaktiere bitte die Organisatoren.\r\n\r\nWenn das Teilnehmerlimit bereits erreicht wurde, erhältst du nach erfolgter Zahlung einen Platz auf der Warteliste (ohne Zahlung wird deine Anmeldung auch für die Warteliste *nicht* berücksichtigt). Danach wirst du per E-Mail informiert, sobald ein Platz für dich frei werden sollte. Falls du keinen freien Teilnehmerplatz mehr erlangen solltest, wird die Anmeldegebühr selbstverständlich erstattet.\r\n\r\n#English: \r\n\\[1) This step is ONLY for **newcomers and competitors without a WCA account**: [Creation of a WCA-account](https://www.worldcubeassociation.org/users/sign_up)]\r\n2) Registration for the competition using the [registration form](https://www.worldcubeassociation.org/competitions/HessenOpen2023/register).\r\n3) **Payment** (**5€** per competitior) via PayPal [*using this link*](https://PayPal.Me/HO2023). Please do **not** activate the optional buyer protection as this will be deducted as a fee from the amount you pay. Please enter the name of the competitor you pay for in the final step of the payment procedure. We cannot accept registrations if we cannot assign the payment.\r\n**The registration is not completed and will not be confirmed until the money is paid.** If you have no access to PayPal, please contact the organization team.\r\n\r\nIf you have registered after the competitor limit has been reached, you will receive a spot on the waiting list (without completed payment, your registration will *not* be added to the waiting list). You will be notified via E-Mail once a spot for you frees up. If you don't obtain a free spot until registration closes, you will get a full refund of your registration fees.",
        'on_the_spot_registration': false,
        'on_the_spot_entry_fee_lowest_denomination': nil,
        'refund_policy_percent': 100,
        'refund_policy_limit_date': '2023-05-13T18:00:00.000Z',
        'guests_entry_fee_lowest_denomination': 0,
        'qualification_results': false,
        'external_registration_page': '',
        'event_restrictions': false,
        'cancelled_at': nil,
        'waiting_list_deadline_date': '2023-05-14T18:00:00.000Z',
        'event_change_deadline_date': '2023-05-13T18:00:00.000Z',
        'guest_entry_status': 'free',
        'allow_registration_edits': true,
        'allow_registration_self_delete_after_acceptance': false,
        'allow_registration_without_qualification': false,
        'guests_per_registration_limit': nil,
        'force_comment_in_registration': false,
        'url': 'https://www.worldcubeassociation.org/competitions/HessenOpen2023',
        'website': 'https://www.worldcubeassociation.org/competitions/HessenOpen2023',
        'short_name': 'Hessen Open 2023',
        'city': 'Lampertheim-Hofheim',
        'venue_address': 'Balthasar-Neumann-Straße 1-3 68623 Lampertheim',
        'venue_details': '',
        'latitude_degrees': 49.660638,
        'longitude_degrees': 8.414024,
        'country_iso2': 'DE',
        'event_ids': %w[333 444 555 333bf 333fm 333oh clock minx pyram skewb sq1 333mbf],
        'registration_opened?': false,
        'main_event_id': '333',
        'number_of_bookmarks': 51,
        'using_stripe_payments?': nil,
        'uses_qualification?': false,
        'uses_cutoff?': true,
        'delegates': [
          {
            id: 7139,
            created_at: '2015-12-20T17:41:42.000Z',
            updated_at: '2023-10-30T20:30:40.000Z',
            name: 'Annika Stein',
            delegate_status: 'candidate_delegate',
            wca_id: '2014STEI03',
            gender: 'f',
            country_iso2: 'DE',
            url: 'https://www.worldcubeassociation.org/persons/2014STEI03',
            country: {
              id: 'Germany',
              name: 'Germany',
              continentId: '_Europe',
              iso2: 'DE',
            },
            email: 'astein@worldcubeassociation.org',
            location: 'Germany',
            senior_delegate_id: 454,
            class: 'user',
            teams: [
              {
                id: 510,
                friendly_id: 'wac',
                leader: false,
                name: 'Annika Stein',
                senior_member: false,
                wca_id: '2014STEI03',
                avatar: {
                  url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2014STEI03/1527407820.jpg',
                  thumb: {
                    url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2014STEI03/1527407820_thumb.jpg',
                  },
                },
              },
            ],
            avatar: {
              url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2014STEI03/1527407820.jpg',
              pending_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              thumb_url:
                'https://avatars.worldcubeassociation.org/uploads/user/avatar/2014STEI03/1527407820_thumb.jpg',
              is_default: false,
            },
          },
          {
            id: 49811,
            created_at: '2017-03-12T14:12:46.000Z',
            updated_at: '2023-10-30T07:51:41.000Z',
            name: 'Laura Holzhauer',
            delegate_status: 'delegate',
            wca_id: '2016HOLZ01',
            gender: 'f',
            country_iso2: 'DE',
            url: 'https://www.worldcubeassociation.org/persons/2016HOLZ01',
            country: {
              id: 'Germany',
              name: 'Germany',
              continentId: '_Europe',
              iso2: 'DE',
            },
            email: 'lholzhauer@worldcubeassociation.org',
            location: 'Germany',
            senior_delegate_id: 454,
            class: 'user',
            teams: [],
            avatar: {
              url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2016HOLZ01/1641847100.jpg',
              pending_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              thumb_url:
                'https://avatars.worldcubeassociation.org/uploads/user/avatar/2016HOLZ01/1641847100_thumb.jpg',
              is_default: false,
            },
          },
          {
            id: 51037,
            created_at: '2017-03-20T21:02:21.000Z',
            updated_at: '2023-10-30T18:26:47.000Z',
            name: 'Ricardo Olea Catalán',
            delegate_status: 'candidate_delegate',
            wca_id: '2017CATA04',
            gender: 'm',
            country_iso2: 'DE',
            url: 'https://www.worldcubeassociation.org/persons/2017CATA04',
            country: {
              id: 'Germany',
              name: 'Germany',
              continentId: '_Europe',
              iso2: 'DE',
            },
            email: 'rcatalan@worldcubeassociation.org',
            location: 'Germany',
            senior_delegate_id: 454,
            class: 'user',
            teams: [],
            avatar: {
              url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2017CATA04/1570127985.jpg',
              pending_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              thumb_url:
                'https://avatars.worldcubeassociation.org/uploads/user/avatar/2017CATA04/1570127985_thumb.jpg',
              is_default: false,
            },
          },
        ],
        'organizers': [
          {
            id: 6247,
            created_at: '2015-10-26T23:05:33.000Z',
            updated_at: '2023-10-27T22:43:01.000Z',
            name: 'Helmut Heilig',
            delegate_status: nil,
            wca_id: '2010HEIL02',
            gender: 'm',
            country_iso2: 'DE',
            url: 'https://www.worldcubeassociation.org/persons/2010HEIL02',
            country: {
              id: 'Germany',
              name: 'Germany',
              continentId: '_Europe',
              iso2: 'DE',
            },
            class: 'user',
            teams: [],
            avatar: {
              url: 'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              pending_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              thumb_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              is_default: true,
            },
          },
          {
            id: 9287,
            created_at: '2016-01-23T01:15:20.000Z',
            updated_at: '2023-06-18T12:19:49.000Z',
            name: 'Fabian Simon',
            delegate_status: nil,
            wca_id: '2011SIMO02',
            gender: 'm',
            country_iso2: 'DE',
            url: 'https://www.worldcubeassociation.org/persons/2011SIMO02',
            country: {
              id: 'Germany',
              name: 'Germany',
              continentId: '_Europe',
              iso2: 'DE',
            },
            class: 'user',
            teams: [],
            avatar: {
              url: 'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              pending_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              thumb_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              is_default: true,
            },
          },
          {
            id: 20859,
            created_at: '2016-06-07T09:57:04.000Z',
            updated_at: '2023-09-15T23:03:37.000Z',
            name: 'Timo Ludwig',
            delegate_status: nil,
            wca_id: '2011LUDW01',
            gender: 'm',
            country_iso2: 'DE',
            url: 'https://www.worldcubeassociation.org/persons/2011LUDW01',
            country: {
              id: 'Germany',
              name: 'Germany',
              continentId: '_Europe',
              iso2: 'DE',
            },
            class: 'user',
            teams: [],
            avatar: {
              url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2011LUDW01/1441150545.jpg',
              pending_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              thumb_url:
                'https://avatars.worldcubeassociation.org/uploads/user/avatar/2011LUDW01/1441150545_thumb.jpg',
              is_default: false,
            },
          },
          {
            id: 143589,
            created_at: '2019-02-14T20:49:45.000Z',
            updated_at: '2023-10-30T09:38:32.000Z',
            name: 'Dominik Beese',
            delegate_status: nil,
            wca_id: '2013BEES01',
            gender: 'm',
            country_iso2: 'DE',
            url: 'https://www.worldcubeassociation.org/persons/2013BEES01',
            country: {
              id: 'Germany',
              name: 'Germany',
              continentId: '_Europe',
              iso2: 'DE',
            },
            class: 'user',
            teams: [],
            avatar: {
              url: 'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              pending_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              thumb_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              is_default: true,
            },
          },
        ],
        'tabs': [
          {
            id: 24368,
            competition_id: 'HessenOpen2023',
            name: 'COVID-19 Safety Rules / COVID-19 Sicherheitsregeln',
            content:
              '## Deutsch\r\nEs gelten die folgenden Sicherheitsvorkehrungen und Regeln:\r\n\r\n- **Mögliche Maskenpflicht/3G-Kontrollen:** Wir behalten uns das Recht vor, eine Maskenpflicht (medizinische Maske/FFP2-Maske) durchzusetzen oder 3G-Kontrollen durchzuführen, sofern die pandemische Lage dies erfordert. Die endgültige Entscheidung dazu wird 1-2 Wochen vor dem Wettbewerb getroffen und spätestens am 13. Mai auf der Website vermerkt sowie den Teilnehmern in einer Rundmail mitgeteilt.\r\n- **Symptome:** Personen, die am Tag des Wettbewerbs Covid-Symptome wie Fieber, Husten oder Abgeschlagenheit zeigen und in der Woche vor dem Wettbewerb mit einem Covid-19-Erkrankten Kontakt hatten, dürfen die Venue nicht betreten und nicht am Wettbewerb teilnehmen. Wer in der Woche vor dem Wettbewerb mit einem Covid-19-Erkrankten Kontakt hatte ODER geringfügige Covid-Symptome wie Husten oder Abgeschlagenheit zeigt, muss vor dem Wettbewerb einen Selbsttest/zertifizierten Schnelltest ("Bürgertest") machen, der natürlich negativ ausfallen muss.\r\n\r\n#### **Achtung: Die oben genannten Regeln dienen der Durchführung einer sicheren Veranstaltung für alle Teilnehmer. Nichtbeachten der Regeln und mutwilliges oder wiederholtes Zuwiderhandeln führen zur Disqualifikation und Ausschluss von der Veranstaltung.**\r\n\r\nDie obigen Regeln erfüllen die aktuell gültige [Corona-Schutzverordnung in Hessen](https://hessen.de/handeln/corona-in-hessen) in vollem Umfang. Bitte beachte, dass wir keinen Einfluss auf gesetzliche Regelungen haben. Sollte es kurzfristig zu Änderungen kommen wegen denen wir unsere COVID-Sicherheits-Richtlinien verschärfen, oder den Wettbewerb sogar komplett absagen müssen, werden alle Teilnehmer per E-Mail benachrichtigt und die Teilnahmegebühr wenn nötig zurückgezahlt.\r\n\r\nFalls du zu Wettbewerb aus einem anderen Land als Deutschland anreisen möchtest, beachte bitte die derzeitigen [Einreiseregelungen für Deutschland](https://www.auswaertiges-amt.de/de/quarantaene-einreise/2371468) und leiste den dort beschriebenen Anweisungen Folge.\r\n\r\n## English\r\nThe following safety rules and precautions apply:\r\n\r\n- **Possible Mask Requirement/3G Control:** We reserve the right to require medical masks/FFP2 masks to be worn during the competition or to conduct 3G controls (vaccinated, recovered, tested) at the competition if the pandemic situation demands this. The final decision will be made one or two week prior to the competition, and on 13th of May the website will be updated as well as all competitors will be informed via email.\r\n- **Symptoms:** Persons that show Covid symptoms such as fever, coughing or fatigue on the day of the competition and were in contact with a Covid-19 patient in the week prior to the competition are not allowed to enter the venue and/or compete. Persons that show weak Covid symptoms such as coughing or fatigue on the day of the competition OR persons that were in contact with a Covid-19 patient in the week prior to the competition have to do a rapid self-test or certified antigen test (with a negative result) prior to attending the competition.\r\n\r\n#### **Attention: The rules stated above serve to ensure the safe execution of the competition for all competitors. Ignoring and willful or repeated violating of these rules will result in disqualification and exclusion from the competition.**\r\n\r\nThe rules above are in compliance with the laws in force (see the [Covid-19 Safety Policy in Hessen](https://hessen.de/handeln/corona-in-hessen)). Please note that we do not have any influence on the regulations set by the laws. In case these laws change and we have to alter our COVID Safety Rules or even cancel the competition entirely, all competitors will be notified via email and the registration fee will be paid back if possible.\r\n\r\nIf you plan to travel to the competition from another country, please take a look at the current [entry restrictions for Germany](https://www.auswaertiges-amt.de/en/coronavirus/2317268) and follow the regulations set there.',
            display_order: 1,
          },
          {
            id: 24369,
            competition_id: 'HessenOpen2023',
            name: ' Neulinge \u0026 Ergebnisse / Newcomers \u0026 Results ',
            content:
              "#Deutsch\r\n\r\n**Informationen für Neulinge**\r\nFalls dies dein erstes WCA Turnier sein sollte, beachte bitte die folgenden Punkte:\r\n\r\n* Alle Neulinge sind dazu verpflichtet, ein **Ausweisdokument** an der Anmeldung vor zu zeigen (Regulation [2e)](https://www.worldcubeassociation.org/regulations/#2e)). Aus dem Dokument müssen Name, Nationalität und Geburtsdatum hervorgehen.\r\n\r\n* Alle Neulinge sind eindringlich gebeten, am **Tutorial** (siehe Zeitplan) teilzunehmen.\r\n\r\n* Jeder Teilnehmer sollte bereits vor der Meisterschaft mindestens einmal die **[offiziellen Regeln der WCA](https://www.worldcubeassociation.org/regulations/translations/german/)** gelesen haben. Zusätzlich empfehlen wir euch einen Blick in das [WCA Competition Tutorial](https://www.worldcubeassociation.org/files/WCA_Competition_Tutorial.pdf). Dort findet ihr wichtige Infos zum Ablaub und zur Teilnahme am Wettbewerb.\r\n* Keine Angst: während des Turniers besteht die Möglichkeit, sich mit dem offiziellen Equipment (Stackmat-Timer) vertraut zu machen und Fragen zu stellen. \r\n* Bei wichtigen Fragen vor dem Turnier kannst du dich gerne [an das Organisationsteam wenden](mailto:Hessen-Open@gmx.de).\r\n\r\nLive Ergebnisse werden hier veröffentlicht: https://live.worldcubeassociation.org/\r\nNach dem Wettkampf werden alle Ergebnisse in die Datenbank der WCA hochgeladen und auf dieser Seite einzusehen sein.\r\n\r\n#English\r\n\r\n**Newcomer information**\r\nIf this is your first WCA competition, please pay attention to the following:\r\n\r\n* According to Regulation [2e)](https://www.worldcubeassociation.org/regulations/#2e), all newcomers are required to bring some form of **identification document**  that shows name, citizenship and date of birth.\r\n\r\n* All newcomers are urgently asked to attend the **Tutorial** (see schedule). \r\n\r\n* Every competitor should have read the [**official WCA regulations**](https://www.worldcubeassociation.org/regulations) at least once before attending the competition! A more condensed version of the important regulations can be found at the [WCA Competition Tutorial](https://www.worldcubeassociation.org/files/WCA_Competition_Tutorial.pdf).\r\n\r\n* Don't be afraid: there will also be time to test the equipment (for example the official timing device, the Stackmat timer) and discuss the rules if you have questions at the competition. \r\n\r\n* Feel free to [contact the organizer](mailto:Hessen-Open@gmx.de) if you have any uncertainties.\r\n\r\nLive results will be available here: https://live.worldcubeassociation.org/\r\nAll results will be uploaded to the WCA database after the competition and will be available right here!\r\n\r\n\r\n",
            display_order: 2,
          },
          {
            id: 24370,
            competition_id: 'HessenOpen2023',
            name: 'Anreise / Travel',
            content:
              "# Deutsch\r\n**Bitte beachtet: Anders als in den Vorjahren steht die Zehntscheune in Lampertheim in diesem Jahr nicht als Austragungsort zur Verfügung. Wir sind daher auf das Bürgerhaus in einem anderen Stadtteil ausgewichen.**\r\n\r\n* Bahnlinie RE70 / S9 aus Richtung Mannheim bzw. Frankfurt, Umstieg auf auf RB63 in Richtung Worms. Alternativ direkt in Worms oder Bensheim in RB63 einsteigen.\r\n* Von Zielhaltestelle Hofheim (Ried) sind es 5 Gehminuten bis zum Bürgerhaus.\r\n* Vorsicht beim Fahren mit Navi: Verwechselt den Lampertheimer Stadtteil Hofheim (Ried) nicht mit Hofheim im Taunus! ;)\r\n* Vor Ort steht nur eine begrenzte Anzahl an Parkplätzen vor der Venue zur Verfügung. \r\n\r\n# English\r\n**Please note: Unlike in previous years, the Zehntscheune in Lampertheim is not available as a venue this year. We have therefore switched to the community center in another part of town.**\r\n\r\n* Train line RE70 / S9 from Mannheim or Frankfurt, change to RB63 in the direction of Worms. Alternatively, board RB63 directly in Worms or Bensheim.\r\n* From the destination stop Hofheim (Ried) it is a 5-minute walk to the Bürgerhaus.\r\n* Caution when driving with navigation systems: Do not confuse Lampertheim's district Hofheim (Ried) with Hofheim im Taunus! ;)\r\n* Only a limited number of parking spaces are available on site in front of the venue. \r\n",
            display_order: 3,
          },
          {
            id: 24371,
            competition_id: 'HessenOpen2023',
            name: 'Verpflegung / Catering',
            content:
              '# Deutsch\r\nEs gibt fußläufig ein paar Restaurants, die man besuchen kann. Unter anderem Howwemer Pizza Kebab, Pizzeria Trattoria da Verona und Pizzeria Paradiso.\r\nWir werden kein Essen verkaufen.\r\n\r\n# English\r\nThere are a few restaurants within walking distance that you can visit. Howwemer Pizza Kebab, Pizzeria Trattoria da Verona and Pizzeria Paradiso among others.\r\nWe will not be selling food.\r\n',
            display_order: 4,
          },
          {
            id: 24372,
            competition_id: 'HessenOpen2023',
            name: 'GCA',
            content:
              '[![](https://www.worldcubeassociation.org/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBcGNqIiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--3f93d32973ed5f3ad112f6e04ddc042b289f871c/Ohne%20Titel.jpg)](https://www.germancubeassociation.de/)\r\n\r\nAlle Wettkämpfe in Deutschland werden von Mitgliedern der [German Cube Association](https://www.germancubeassociation.de/) und weiteren freiwilligen Organisatoren aus dem ganzen Land durchgeführt. Bitte kommt auf uns zu, wenn auch ihr Interesse am Organisieren eines Turniers habt.\r\nAll competitions in Germany are run by members of the [German Cube Association](https://www.germancubeassociation.de/) and further voluntary organisers from all over the country. Please approach us if you are interested in hosting a competition.\r\n\r\nFolge uns auf unseren Social-Media-Seiten, um über die neuesten Inhalte und Ankündigungen auf dem Laufenden zu bleiben!\r\nFollow us on social media to stay up to date with new information and announcements!\r\n\r\n[![](https://www.worldcubeassociation.org/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBcEVqIiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--c465d8deba5509ea829e38813e375c7a7b846b3f/fFmmADt.png)](https://www.instagram.com/germancubeassociation/) [![](https://www.worldcubeassociation.org/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBcFVqIiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--500c3d9550cb8161085be58845afbf73b50190e7/Bildschirmfoto%202022-09-25%20um%2012.08.41.png)](https://www.twitch.tv/germanonlinecubing2020/)',
            display_order: 5,
          },
          {
            id: 26843,
            competition_id: 'HessenOpen2023',
            name: 'Warteliste / Waiting List',
            content:
              'Die Warteliste wird manuell aktualisiert. Deshalb kann es nach vollständiger Anmeldung (=Anmeldung+Zahlung der Teilnahmegebühr) etwas dauern, bis Dein Name auf der Liste auftaucht. / The waiting list is updated manually. It might take a while until your name appears on the list after you have completed your registration (=registered and paid the fee).\r\n \r\nDerzeit keine Warteliste/ There is no waiting list currently.',
            display_order: 6,
          },
        ],
        'class': 'competition',
      }
    when "ManchesterSpring2024"
      {
        'id': 'ManchesterSpring2024',
        'name': 'Manchester Spring 2024',
        'information':
          'If you are a new competitor, please make sure to read all the information in the **FAQ** and the **Important Information** tabs before registering. All competitors should be familiar with the information in these tabs.\r\n\r\n**Spectators may attend for free!**\r\n\r\n[![Imgur](https://i.imgur.com/OXOffhf.png)](https://www.ukca.org/)\r\n',
        'venue': 'Wythenshawe Forum',
        'contact': '',
        'registration_open': self.date_from_now(1),
        'registration_close': self.date_from_now(2),
        'use_wca_registration': true,
        'announced_at': '2023-09-12T21:59:02.000Z',
        'base_entry_fee_lowest_denomination': 4000,
        'currency_code': 'GBP',
        'start_date': self.date_from_now(3),
        'end_date': self.date_from_now(3, 1),
        'enable_donations': false,
        'competitor_limit': 120,
        'extra_registration_requirements':
          'Make sure to register **and pay** for the competition to be accepted. We will not accept any registrations at the competition.\r\n\r\nOnce you have been accepted, you will receive a confirmation email. If registration is full by the time you pay then you will **not** receive this confirmation email and you will be on the *waiting list*. If you do not make the competitor list by the limit date for refunds (specified above), then you will be refunded 100% of your registration fee. You may contact us to ask for your current position on the waiting list.\r\n\r\n**If you can no longer attend, let us know as soon as possible** through the contact link on the [General Info]() page. We often have waiting lists so letting us know you cannot attend allows us to add another person to the competition.\r\n\r\n**If you would like to change events,** you can do so on the register page by simply reselecting your events list, and clicking "Update Registration".\r\n\r\nRegistration changes and deletions will **only** be processed after a request through the contact form. We will **not** accept any changes to registrations via any other platform.\r\n\r\nIf you have any problems check out the FAQ, or feel free to contact us.',
        'on_the_spot_registration': false,
        'on_the_spot_entry_fee_lowest_denomination': nil,
        'refund_policy_percent': 75,
        'refund_policy_limit_date': self.date_from_now(2),
        'guests_entry_fee_lowest_denomination': 0,
        'qualification_results': false,
        'external_registration_page': '',
        'event_restrictions': false,
        'cancelled_at': nil,
        'waiting_list_deadline_date': self.date_from_now(2),
        'event_change_deadline_date': self.date_from_now(2),
        'guest_entry_status': 'unclear',
        'allow_registration_edits': true,
        'allow_registration_self_delete_after_acceptance': false,
        'allow_registration_without_qualification': false,
        'guests_per_registration_limit': nil,
        'force_comment_in_registration': false,
        'url':
          'https://www.worldcubeassociation.org/competitions/ManchesterSpring2024',
        'website':
          'https://www.worldcubeassociation.org/competitions/ManchesterSpring2024',
        'short_name': 'Manchester Spring 2024',
        'city': 'Manchester, Greater Manchester',
        'venue_address': 'Forum Centre, Simonsway, Wythenshawe, Manchester M22 5RX',
        'venue_details': 'Forum Hall',
        'latitude_degrees': 53.379712,
        'longitude_degrees': -2.265415,
        'country_iso2': 'GB',
        'event_ids': %w[333 222 444 555 666 777 333bf 333fm 333oh clock minx pyram skewb sq1 444bf 555bf 333mbf],
        'registration_opened?': false,
        'main_event_id': '333',
        'number_of_bookmarks': 100,
        'using_stripe_payments?': false,
        'uses_qualification?': false,
        'uses_cutoff?': true,
        'delegates': [
          {
            id: 2,
            created_at: '2012-07-25T05:42:29.000Z',
            updated_at: '2023-10-25T17:31:40.000Z',
            name: 'Sébastien Auroux',
            delegate_status: 'delegate',
            wca_id: '2008AURO01',
            gender: 'm',
            country_iso2: 'DE',
            url: 'https://www.worldcubeassociation.org/persons/2008AURO01',
            country: {
              id: 'Germany',
              name: 'Germany',
              continentId: '_Europe',
              iso2: 'DE',
            },
            email: 'sauroux@worldcubeassociation.org',
            location: 'Germany',
            senior_delegate_id: 454,
            class: 'user',
            teams: [
              {
                id: 190,
                friendly_id: 'wrt',
                leader: true,
                name: 'Sébastien Auroux',
                senior_member: false,
                wca_id: '2008AURO01',
                avatar: {
                  url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2008AURO01/1630621356.jpg',
                  thumb: {
                    url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2008AURO01/1630621356_thumb.jpg',
                  },
                },
              },
            ],
            avatar: {
              url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2008AURO01/1630621356.jpg',
              pending_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              thumb_url:
                'https://avatars.worldcubeassociation.org/uploads/user/avatar/2008AURO01/1630621356_thumb.jpg',
              is_default: false,
            },
          },
          {
            id: 6858,
            created_at: '2015-12-04T02:47:21.000Z',
            updated_at: '2023-10-29T10:42:37.000Z',
            name: 'Nevins Chan Pak Hoong (陈百鸿)',
            delegate_status: 'delegate',
            wca_id: '2010CHAN20',
            gender: 'm',
            country_iso2: 'MY',
            url: 'https://www.worldcubeassociation.org/persons/2010CHAN20',
            country: {
              id: 'Malaysia',
              name: 'Malaysia',
              continentId: '_Asia',
              iso2: 'MY',
            },
            email: 'nhoong@worldcubeassociation.org',
            location: 'United Kingdom (North West)',
            senior_delegate_id: 454,
            class: 'user',
            teams: [
              {
                id: 347,
                friendly_id: 'wqac',
                leader: false,
                name: 'Nevins Chan Pak Hoong (陈百鸿)',
                senior_member: false,
                wca_id: '2010CHAN20',
                avatar: {
                  url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2010CHAN20/1644296027.jpg',
                  thumb: {
                    url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2010CHAN20/1644296027_thumb.jpg',
                  },
                },
              },
              {
                id: 529,
                friendly_id: 'wcat',
                leader: false,
                name: 'Nevins Chan Pak Hoong (陈百鸿)',
                senior_member: false,
                wca_id: '2010CHAN20',
                avatar: {
                  url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2010CHAN20/1644296027.jpg',
                  thumb: {
                    url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2010CHAN20/1644296027_thumb.jpg',
                  },
                },
              },
            ],
            avatar: {
              url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2010CHAN20/1644296027.jpg',
              pending_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              thumb_url:
                'https://avatars.worldcubeassociation.org/uploads/user/avatar/2010CHAN20/1644296027_thumb.jpg',
              is_default: false,
            },
          },
        ],
        'organizers': [
          {
            id: 6858,
            created_at: '2015-12-04T02:47:21.000Z',
            updated_at: '2023-10-29T10:42:37.000Z',
            name: 'Nevins Chan Pak Hoong (陈百鸿)',
            delegate_status: 'delegate',
            wca_id: '2010CHAN20',
            gender: 'm',
            country_iso2: 'MY',
            url: 'https://www.worldcubeassociation.org/persons/2010CHAN20',
            country: {
              id: 'Malaysia',
              name: 'Malaysia',
              continentId: '_Asia',
              iso2: 'MY',
            },
            email: 'nhoong@worldcubeassociation.org',
            location: 'United Kingdom (North West)',
            senior_delegate_id: 454,
            class: 'user',
            teams: [
              {
                id: 347,
                friendly_id: 'wqac',
                leader: false,
                name: 'Nevins Chan Pak Hoong (陈百鸿)',
                senior_member: false,
                wca_id: '2010CHAN20',
                avatar: {
                  url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2010CHAN20/1644296027.jpg',
                  thumb: {
                    url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2010CHAN20/1644296027_thumb.jpg',
                  },
                },
              },
              {
                id: 529,
                friendly_id: 'wcat',
                leader: false,
                name: 'Nevins Chan Pak Hoong (陈百鸿)',
                senior_member: false,
                wca_id: '2010CHAN20',
                avatar: {
                  url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2010CHAN20/1644296027.jpg',
                  thumb: {
                    url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2010CHAN20/1644296027_thumb.jpg',
                  },
                },
              },
            ],
            avatar: {
              url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2010CHAN20/1644296027.jpg',
              pending_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              thumb_url:
                'https://avatars.worldcubeassociation.org/uploads/user/avatar/2010CHAN20/1644296027_thumb.jpg',
              is_default: false,
            },
          },
          {
            id: 256443,
            created_at: '2022-02-16T22:12:53.000Z',
            updated_at: '2023-10-30T17:50:24.000Z',
            name: 'UK Cube Association',
            delegate_status: nil,
            wca_id: nil,
            gender: 'o',
            country_iso2: 'GB',
            url: '',
            country: {
              id: 'United Kingdom',
              name: 'United Kingdom',
              continentId: '_Europe',
              iso2: 'GB',
            },
            class: 'user',
            teams: [],
            avatar: {
              url: 'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              pending_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              thumb_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              is_default: true,
            },
          },
        ],
        'tabs': [
          {
            id: 33677,
            competition_id: 'ManchesterSpring2024',
            name: 'UKCA',
            content:
              "[![UKCA](https://i.imgur.com/AiMcFVw.png)](https://www.ukca.org/)\r\n\r\nHello! We are the [UK Cube Association](https://www.ukca.org/) and we are a completely volunteer-ran organisation that hosts all cubing competitions in the UK. We are made up of a team of 8 delegates as well as 3 social media and graphic design staff, and we're passionate about giving people as many opportunities to compete in the UK as we can. We have organised over 100 competitions up and down the country with many more on the horizon and are always trying to find new locations to make cubing competitions as accessible as possible.\r\n\r\nMake sure to follow our social media pages to keep up to date with the latest content and media!\r\n\r\n[![Image description](https://i.imgur.com/4HaEaRW.png)](https://www.facebook.com/UKCubeAssociation/)       [![Image description](https://i.imgur.com/fFmmADt.png)](https://www.instagram.com/ukcubeassociation)       [![Image description](https://i.imgur.com/7YIQNYo.png)](https://twitter.com/CubeAssociation)       [![Image description](https://i.imgur.com/fOFmbuR.png)](https://discord.gg/Gb7Fxsc)     \r\n\r\nUKCA is committed to safeguarding the welfare of children and young people under the age of 18 who attend our activities. Please read our [Safeguarding Policy](https://www.ukca.org/safeguarding) for more information about this. If you have any concerns, please contact us at SafeguardingUKCA@gmail.com.",
            display_order: 1,
          },
          {
            id: 33678,
            competition_id: 'ManchesterSpring2024',
            name: 'FAQ',
            content:
              "# Frequently Asked Questions\r\n\r\n### First time at our competitions?\r\n\r\n**Q: How do I register?**\r\n**A**: Make sure you have created a WCA account by going to the [sign-up page](https://www.worldcubeassociation.org/users/sign_up) and creating an account. Once you have created the account and confirmed your email address, follow the menu bar to the [*Register*](https://www.worldcubeassociation.org/competitions/ABHM2023/register) page and carefully follow the instructions.\r\n\r\n**Q: Can I come only to spectate?**\r\n**A**: Yes! There is no need to book - you can just rock up on the day. It can be a bit hectic in the mornings so afternoon is preferred.\r\n\r\n**Q: Are there different age categories?**\r\n**A**: No, all competitors compete on the same level and all ages are welcome.\r\n\r\n**Q: Am I allowed to bring a guest?**\r\n**A**: Yes, you can bring as many guests as you want.\r\n\r\n**Q: How fast do I have to be to compete?**\r\n**A**: Check out the Events tab - if you can make the time limit for the events you want to compete in, then you're fast enough!\r\n\r\n**Q: Do I have to be there on both days?**\r\n**A**: No, if you only have events on one of the days, you don't have to turn up for the other day. You can see what days your events are on on the Schedule tab.\r\n\r\n**Q: When can I leave the competition?**\r\n**A**: You are welcome to leave whenever you are not competing. If you have no more events left then you are not required to stay.\r\n\r\n**Q: Do I use my own cubes to compete?**\r\n**A**: Yes!\r\n\r\n**Q: How do I find live results?**\r\n**A**: You can see live results as soon as they're entered at [WCA Live](https://live.worldcubeassociation.org/).\r\n\r\n**Q: What happens to my results after the competition?**\r\n**A**: Within a couple of days, they will all be posted to this page and if this is your first competition you will automatically have your very own WCA ID assigned.\r\n\r\n**Q: Do you have a mailing list?**\r\n**A**: Why yes, we do have a mailing list! Sign up [here](https://www.ukca.org/) for announcements of future competitions and more.\r\n\r\n### Need to unregister?\r\n\r\n**Q: What do I do if I can no longer attend?**\r\n**A**: Let us know via the contact link on the [General Info]() page.\r\n\r\n**Q: If I do not attend do I get a refund?**\r\n**A**: If you inform us you are no longer attending before the limit date for refunds on the [General Info]() page then you will receive a 75% refund. If this time has passed then you will receive no refund.",
            display_order: 2,
          },
          {
            id: 33679,
            competition_id: 'ManchesterSpring2024',
            name: 'Important Information',
            content:
              "###New Competitors\r\n\r\nTo register, make sure you have created a WCA account by going to the [sign-up page](https://www.worldcubeassociation.org/users/sign_up) and creating an account. Once you have created the account and confirmed your email address, follow the menu bar to the *Register* page and carefully follow the instructions.\r\n\r\nIf you are a new competitor, please make sure to:\r\n\r\n* Familiarise yourself with the [WCA Regulations](https://www.worldcubeassociation.org/regulations/) by watching this [tutorial for new competitors video](https://youtu.be/8dSuMG--wm8). We will also be holding a live tutorial on both mornings of the competition.\r\n\r\n* **Bring some form of ID with you** such as your passport, driver's licence, or birth certificate. Expired ID or photos of ID are both accepted.\r\n\r\n\r\n###Information for All Competitors\r\n\r\n* **Schedule Changes**: Please note that the schedule is subject to change up until the Wednesday before the competition. Any major changes should be communicated in the precompetition email.\r\n\r\n* **Please help judge!** As a competitor, your judging assignments are the absolute minimum you should be doing to help out. Since second rounds, third rounds and finals have no assigned judges, we really need people to help out whenever available for these. If you're a parent you can also get involved with running and juging, it's really easy! We will have a judging tutorial in the mornings as well, which will run through the process and will be tailored towards parents who want to get involved.\r\n\r\n* **No flash photography** anywhere in the venue.\r\n\r\n* If you are a spectator, please **never** stand further forward than the front row of spectator chairs.\r\n\r\n* We will be taking videos and photographs of the competition and the environment for our social media pages and website. By attending the competition as a competitor or a guest, you are accepting that you may be filmed or photographed for these purposes.",
            display_order: 3,
          },
          {
            id: 33680,
            competition_id: 'ManchesterSpring2024',
            name: 'Travel',
            content:
              "![](https://www.worldcubeassociation.org/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBblU3IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--6f87aa4fdbed83bf8b6a7804d310f107f5c23b7b/image.png)\r\n###Venue\r\nThe Forum Hall is located in the Forum Centre, the entrance is marked red in the screenshot above.\r\n\r\n###Travel\r\n**Car:** The car park is just right in front of the entrance of the venue as shown in the screenshot above. Please note that the car park isn't free.\r\n**Train:** The closest train station is Manchester Airport. Alternatively, you can also get to Manchester Piccadilly. You can get to the venue from both train stations using tram/bus service.\r\n**Plane:** The closest airport is Manchester(MAN), the venue is 6 minutes drive away.\r\n**Coach:** Manchester Coach station and Manchester Airport is regularly serviced by coach services, you can get to the venue using tram/bus service from both.\r\n**Bus:** The venue is just next to Wythenshawe Interchange which service a lot of bus routes from the local area. Wythenshawe Interchange is 2 minutes walk from the venue.\r\n**Tram:** The closest tram station is Wythenshawe Town Centre which is 5 minutes walk away.\r\n\r\n###Accommodation\r\n\r\nDue to the venue's proximity to the airport, majority of the hotels are based next to the airport. [Holiday Inn Manchester Airport](https://www.ihg.com/holidayinn/hotels/gb/en/manchester-airport/manap/hoteldetail) has allocated us 20 rooms at the reduced rate of £130/night including breakfast on a first come first serve basis. To take advantage of this offer, please email reservations@himanchesterairport.com **before 29th Feb** quoting UK Cube Association to book.\r\n",
            display_order: 4,
          },
          {
            id: 33681,
            competition_id: 'ManchesterSpring2024',
            name: 'Groups',
            content:
              'Each event is run in groups, depending on how many people are competing in the event depends on how many groups there are. We call each group up one at a time in order to complete their solves during the scheduled time for the round. We have software that automatically picks what groups you are in, the judges, and who scrambles for each group. This is the minimum amount you should be helping out as it only is for first rounds. We always appreciate extra help!\r\n\r\n**Please note down which groups you are competing and scrambling in before arriving at the competition!**\r\n\r\n## Groups\r\nTBC after registration closed.',
            display_order: 5,
          },
          {
            id: 33765,
            competition_id: 'ManchesterSpring2024',
            name: 'Holiday Inn Reduced Rate',
            content:
              '[Holiday Inn Manchester Airport](https://www.ihg.com/holidayinn/hotels/gb/en/manchester-airport/manap/hoteldetail) has allocated us 20 rooms at the reduced rate of £130/night including breakfast on a first come first serve basis for the weekend. To take advantage of this offer, please email reservations@himanchesterairport.com **before 29th Feb** quoting UK Cube Association to book.',
            display_order: 6,
          },
        ],
        'class': 'competition',
      }
    when "PickeringFavouritesAutumn2023"
      {
        'id': 'PickeringFavouritesAutumn2023',
        'name': 'Pickering Favourites Autumn 2023',
        'information':
          '[![](https://www.worldcubeassociation.org/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBcGd3IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--413963af1d32608ec1038d304a181c8adedb8510/SpeedcubingCanadaLogo-724.png)](https://www.speedcubingcanada.org/)\r\n\r\n## Ontario Favourites Autumn 2023 Series\r\n\r\nThis competition is in a series with [Waterloo Favourites Autumn 2023](https://www.worldcubeassociation.org/competitions/WaterlooFavouritesAutumn2023). You will only be able to compete in ***one*** of these two competitions. ***Attempting to register for both competitions will result in only one of your registrations being accepted.***\r\n\r\n### Registration Reminders\r\n\r\nSince this is a "favourites" competition, **you may choose at most five (5) events**. \r\n\r\nYou must register *and pay the registration fee* before your registration can be accepted. Unpaid registrations will not be accepted and registration fees will not be transferred across competitions. See the **Competitor List** and **Waiting List** sections near the bottom of this page for more details.\r\n\r\n### Mailing List\r\n\r\nWe are working hard to meet and keep up with the demand for competitions in southern Ontario and are regularly planning and announcing more competitions. Please follow [Speedcubing Canada](https://www.speedcubingcanada.org/) on social media and/or [join our mailing list](https://share.hsforms.com/1eWkfr6anSF-HKTZJVrElZQcrqzz) to keep up-to-date on competition announcements.\r\n\r\n### Notice of Filming and Photography\r\n\r\nAttendees of Speedcubing Canada competitions consent to their images being used by Speedcubing Canada and its partners in marketing materials, social media and other digital platforms.',
        'venue':
          '[Chestnut Hill Developments Recreation Complex](https://www.pickering.ca/en/living/LocationPRC.aspx)',
        'contact': 'info+pickering-favourites-autumn-2023@speedcubingcanada.org',
        'registration_open': self.date_from_now(-3),
        'registration_close': self.date_from_now(1),
        'use_wca_registration': true,
        'announced_at': '2023-07-23T23:22:13.000Z',
        'base_entry_fee_lowest_denomination': 3500,
        'currency_code': 'CAD',
        'start_date': '2023-12-16',
        'end_date': '2023-12-16',
        'enable_donations': false,
        'competitor_limit': 160,
        'extra_registration_requirements':
          '## Competitor List\r\n\r\nRegistrants must pay the registration fee in order to be added to the [competitor list](https://www.worldcubeassociation.org/competitions/PickeringFavouritesAutumn2023/registrations). Unpaid registrations will not be accepted. Organizers manually accept registrations one at a time in the order the registration fees are paid, so your name may not appear on the competitor list immediately.\r\n\r\nOnce the competitor list reaches the 160 competitor limit, registrants who pay the registration fee will be added to the **waiting list** instead of the competitor list. Due to the competitor limit, completing your registration within the initial registration period does not guarantee you a spot on the competitor list.\r\n\r\n## Waiting List\r\n\r\nThe waiting list is ordered based on the timestamp that registrants paid the registration fee. If you are added to the waiting list you will be informed via an email. Additionally, you can ask about your position on the waiting list by emailing Speedcubing Canada.\r\n\r\nIf anyone on the competitor list deletes their registration, the person at the top of the waiting list will be moved to the competitor list. After December 7, 2023, the competitor list will be finalized and registrants who are still on the waiting list will be refunded 100% of their registration fee. Registrants on the waiting list may email Speedcubing Canada at any time to forfeit their spot on the waiting list and be refunded 100% of their registration fee.\r\n\r\nIf the competitor list fills up quickly, registration could close earlier than the originally listed date (December 7, 2023). The waiting list will close at the same time that registration closes.\r\n\r\n## Favourites Competition\r\n\r\nSince this is a "favourites" competition, you may choose at most five (5) events. **Registrations with more than five (5) events will NOT be accepted.**',
        'on_the_spot_registration': false,
        'on_the_spot_entry_fee_lowest_denomination': nil,
        'refund_policy_percent': 95,
        'refund_policy_limit_date': self.date_from_now(0, 1),
        'guests_entry_fee_lowest_denomination': 0,
        'qualification_results': false,
        'external_registration_page': '',
        'event_restrictions': true,
        'cancelled_at': nil,
        'waiting_list_deadline_date': self.date_from_now(0, 1),
        'event_change_deadline_date': self.date_from_now(0, -1),
        'guest_entry_status': 'restricted',
        'allow_registration_edits': true,
        'allow_registration_self_delete_after_acceptance': false,
        'allow_registration_without_qualification': true,
        'guests_per_registration_limit': 1,
        'force_comment_in_registration': false,
        'url':
          'https://www.worldcubeassociation.org/competitions/PickeringFavouritesAutumn2023',
        'website':
          'https://www.worldcubeassociation.org/competitions/PickeringFavouritesAutumn2023',
        'short_name': 'Pickering Favourites Autumn 2023',
        'city': 'Pickering, Ontario',
        'venue_address': '1867 Valley Farm Road, Pickering, ON',
        'venue_details': 'Banquet Halls, East \u0026 West Salons',
        'latitude_degrees': 43.838901,
        'longitude_degrees': -79.080555,
        'country_iso2': 'CA',
        'event_ids': %w[333 222 444 555 666 777 333oh clock minx pyram skewb sq1],
        'registration_opened?': true,
        'main_event_id': nil,
        'number_of_bookmarks': 68,
        'using_stripe_payments?': false,
        'uses_qualification?': false,
        'uses_cutoff?': true,
        'delegates': [
          {
            id: 547,
            created_at: '2015-06-08T12:24:19.000Z',
            updated_at: '2023-10-30T18:47:57.000Z',
            name: 'Shanglin Ye',
            delegate_status: 'trainee_delegate',
            wca_id: '2013YESH01',
            gender: 'm',
            country_iso2: 'CA',
            url: 'https://www.worldcubeassociation.org/persons/2013YESH01',
            country: {
              id: 'Canada',
              name: 'Canada',
              continentId: '_North America',
              iso2: 'CA',
            },
            email: 'sam.shanglin.ye@gmail.com',
            location: 'Canada (Ontario)',
            senior_delegate_id: 705,
            class: 'user',
            teams: [],
            avatar: {
              url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2013YESH01/1692916002.jpg',
              pending_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              thumb_url:
                'https://avatars.worldcubeassociation.org/uploads/user/avatar/2013YESH01/1692916002_thumb.jpg',
              is_default: false,
            },
          },
          {
            id: 1352,
            created_at: '2015-08-06T18:46:34.000Z',
            updated_at: '2023-10-23T19:36:45.000Z',
            name: 'Sarah Strong',
            delegate_status: 'delegate',
            wca_id: '2007STRO01',
            gender: 'f',
            country_iso2: 'CA',
            url: 'https://www.worldcubeassociation.org/persons/2007STRO01',
            country: {
              id: 'Canada',
              name: 'Canada',
              continentId: '_North America',
              iso2: 'CA',
            },
            email: 'sstrong@worldcubeassociation.org',
            location: 'Canada (Ontario)',
            senior_delegate_id: 705,
            class: 'user',
            teams: [],
            avatar: {
              url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2007STRO01/1533142426.png',
              pending_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              thumb_url:
                'https://avatars.worldcubeassociation.org/uploads/user/avatar/2007STRO01/1533142426_thumb.png',
              is_default: false,
            },
          },
          {
            id: 5952,
            created_at: '2015-10-10T14:25:01.000Z',
            updated_at: '2023-10-30T14:39:02.000Z',
            name: 'Liam Orovec',
            delegate_status: 'delegate',
            wca_id: '2014OROV01',
            gender: 'm',
            country_iso2: 'CA',
            url: 'https://www.worldcubeassociation.org/persons/2014OROV01',
            country: {
              id: 'Canada',
              name: 'Canada',
              continentId: '_North America',
              iso2: 'CA',
            },
            email: 'lorovec@worldcubeassociation.org',
            location: 'Canada (Ontario)',
            senior_delegate_id: 705,
            class: 'user',
            teams: [],
            avatar: {
              url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2014OROV01/1689884477.jpg',
              pending_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              thumb_url:
                'https://avatars.worldcubeassociation.org/uploads/user/avatar/2014OROV01/1689884477_thumb.jpg',
              is_default: false,
            },
          },
          {
            id: 6898,
            created_at: '2015-12-07T02:00:04.000Z',
            updated_at: '2023-10-30T17:41:07.000Z',
            name: 'Abdullah Gulab',
            delegate_status: 'delegate',
            wca_id: '2014GULA02',
            gender: 'm',
            country_iso2: 'PK',
            url: 'https://www.worldcubeassociation.org/persons/2014GULA02',
            country: {
              id: 'Pakistan',
              name: 'Pakistan',
              continentId: '_Asia',
              iso2: 'PK',
            },
            email: 'agulab@worldcubeassociation.org',
            location: 'Canada',
            senior_delegate_id: 705,
            class: 'user',
            teams: [
              {
                id: 667,
                friendly_id: 'wdc',
                leader: false,
                name: 'Abdullah Gulab',
                senior_member: false,
                wca_id: '2014GULA02',
                avatar: {
                  url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2014GULA02/1649125122.jpg',
                  thumb: {
                    url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2014GULA02/1649125122_thumb.jpg',
                  },
                },
              },
            ],
            avatar: {
              url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2014GULA02/1649125122.jpg',
              pending_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              thumb_url:
                'https://avatars.worldcubeassociation.org/uploads/user/avatar/2014GULA02/1649125122_thumb.jpg',
              is_default: false,
            },
          },
          {
            id: 7961,
            created_at: '2016-01-10T23:51:02.000Z',
            updated_at: '2023-10-30T14:24:47.000Z',
            name: 'Tarandeep Mittal',
            delegate_status: 'candidate_delegate',
            wca_id: '2014MITT02',
            gender: 'm',
            country_iso2: 'CA',
            url: 'https://www.worldcubeassociation.org/persons/2014MITT02',
            country: {
              id: 'Canada',
              name: 'Canada',
              continentId: '_North America',
              iso2: 'CA',
            },
            email: 'tmittal@worldcubeassociation.org',
            location: 'Canada (Ontario)',
            senior_delegate_id: 705,
            class: 'user',
            teams: [],
            avatar: {
              url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2014MITT02/1660050086.jpeg',
              pending_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              thumb_url:
                'https://avatars.worldcubeassociation.org/uploads/user/avatar/2014MITT02/1660050086_thumb.jpeg',
              is_default: false,
            },
          },
          {
            id: 12958,
            created_at: '2016-02-25T21:38:26.000Z',
            updated_at: '2023-10-30T16:25:10.000Z',
            name: 'Jonathan Esparaz',
            delegate_status: 'delegate',
            wca_id: '2013ESPA01',
            gender: 'm',
            country_iso2: 'CA',
            url: 'https://www.worldcubeassociation.org/persons/2013ESPA01',
            country: {
              id: 'Canada',
              name: 'Canada',
              continentId: '_North America',
              iso2: 'CA',
            },
            email: 'jesparaz@worldcubeassociation.org',
            location: 'Canada (Ontario)',
            senior_delegate_id: 705,
            class: 'user',
            teams: [],
            avatar: {
              url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2013ESPA01/1650059250.jpg',
              pending_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              thumb_url:
                'https://avatars.worldcubeassociation.org/uploads/user/avatar/2013ESPA01/1650059250_thumb.jpg',
              is_default: false,
            },
          },
          {
            id: 27885,
            created_at: '2016-08-23T01:05:56.000Z',
            updated_at: '2023-10-25T17:38:36.000Z',
            name: 'Hevelyn Sato',
            delegate_status: 'trainee_delegate',
            wca_id: '2011SATO02',
            gender: 'f',
            country_iso2: 'BR',
            url: 'https://www.worldcubeassociation.org/persons/2011SATO02',
            country: {
              id: 'Brazil',
              name: 'Brazil',
              continentId: '_South America',
              iso2: 'BR',
            },
            email: 'hevelynsato@gmail.com',
            location: 'Canada (Toronto)',
            senior_delegate_id: 705,
            class: 'user',
            teams: [],
            avatar: {
              url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2011SATO02/1682294250.jpg',
              pending_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              thumb_url:
                'https://avatars.worldcubeassociation.org/uploads/user/avatar/2011SATO02/1682294250_thumb.jpg',
              is_default: false,
            },
          },
          {
            id: 29576,
            created_at: '2016-09-14T01:40:24.000Z',
            updated_at: '2023-10-30T18:46:27.000Z',
            name: 'Nicholas McKee',
            delegate_status: 'trainee_delegate',
            wca_id: '2015MCKE02',
            gender: 'm',
            country_iso2: 'CA',
            url: 'https://www.worldcubeassociation.org/persons/2015MCKE02',
            country: {
              id: 'Canada',
              name: 'Canada',
              continentId: '_North America',
              iso2: 'CA',
            },
            email: 'nmckee@worldcubeassociation.org',
            location: 'USA (Massachusetts)',
            senior_delegate_id: 705,
            class: 'user',
            teams: [
              {
                id: 587,
                friendly_id: 'wdc',
                leader: false,
                name: 'Nicholas McKee',
                senior_member: false,
                wca_id: '2015MCKE02',
                avatar: {
                  url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2015MCKE02/1675468493.jpeg',
                  thumb: {
                    url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2015MCKE02/1675468493_thumb.jpeg',
                  },
                },
              },
            ],
            avatar: {
              url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2015MCKE02/1675468493.jpeg',
              pending_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              thumb_url:
                'https://avatars.worldcubeassociation.org/uploads/user/avatar/2015MCKE02/1675468493_thumb.jpeg',
              is_default: false,
            },
          },
          {
            id: 45777,
            created_at: '2017-02-12T02:37:33.000Z',
            updated_at: '2023-10-30T21:14:39.000Z',
            name: 'Alyssa Esparaz',
            delegate_status: 'candidate_delegate',
            wca_id: '2014ESPA01',
            gender: 'f',
            country_iso2: 'CA',
            url: 'https://www.worldcubeassociation.org/persons/2014ESPA01',
            country: {
              id: 'Canada',
              name: 'Canada',
              continentId: '_North America',
              iso2: 'CA',
            },
            email: 'aesparaz@worldcubeassociation.org',
            location: 'Canada (Ontario)',
            senior_delegate_id: 705,
            class: 'user',
            teams: [],
            avatar: {
              url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2014ESPA01/1657554427.jpg',
              pending_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              thumb_url:
                'https://avatars.worldcubeassociation.org/uploads/user/avatar/2014ESPA01/1657554427_thumb.jpg',
              is_default: false,
            },
          },
          {
            id: 135516,
            created_at: '2018-12-25T13:13:18.000Z',
            updated_at: '2023-10-22T10:39:28.000Z',
            name: 'Michael Zheng',
            delegate_status: 'candidate_delegate',
            wca_id: '2015ZHEN17',
            gender: 'm',
            country_iso2: 'CA',
            url: 'https://www.worldcubeassociation.org/persons/2015ZHEN17',
            country: {
              id: 'Canada',
              name: 'Canada',
              continentId: '_North America',
              iso2: 'CA',
            },
            email: 'mzheng1@worldcubeassociation.org',
            location: 'Canada (Ontario)',
            senior_delegate_id: 705,
            class: 'user',
            teams: [],
            avatar: {
              url: 'https://avatars.worldcubeassociation.org/uploads/user/avatar/2015ZHEN17/1660271170.jpeg',
              pending_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              thumb_url:
                'https://avatars.worldcubeassociation.org/uploads/user/avatar/2015ZHEN17/1660271170_thumb.jpeg',
              is_default: false,
            },
          },
        ],
        'organizers': [
          {
            id: 287748,
            created_at: '2022-07-18T23:42:59.000Z',
            updated_at: '2023-10-29T01:54:54.000Z',
            name: 'Speedcubing Canada',
            delegate_status: nil,
            wca_id: nil,
            gender: 'o',
            country_iso2: 'CA',
            url: '',
            country: {
              id: 'Canada',
              name: 'Canada',
              continentId: '_North America',
              iso2: 'CA',
            },
            class: 'user',
            teams: [],
            avatar: {
              url: 'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              pending_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              thumb_url:
                'https://www.worldcubeassociation.org/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png',
              is_default: true,
            },
          },
        ],
        'tabs': [
          {
            id: 29243,
            competition_id: 'PickeringFavouritesAutumn2023',
            name: 'Sponsor – Cubing Out Loud',
            content:
              '[![](https://www.worldcubeassociation.org/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBcVl1IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--eef346600a81fc88639efc4f34a927e5431bfb59/logo.webp)\r\n](https://www.cubingoutloud.com)\r\n\r\n### Vending\r\n\r\n[Cubing Out Loud](https://www.cubingoutloud.com) will be on site selling a selection of WCA and non-WCA puzzles, lube, and other accessories. Cash and credit cards are accepted.\r\n\r\n### Pick-up code\r\n\r\nAlready know what you want? Skip the line by using code **PickeringAutumnPickup** to preorder your merch for pickup at their kiosk. The code is valid until Friday, December 15, 2023 at 8:00 PM Eastern.\r\n\r\n### Prizes\r\n\r\n[Cubing Out Loud](https://www.cubingoutloud.com) is sponsoring this competition and will provide gift cards to all podium finishers for use at their online store:\r\n\r\n1st place: $10.00\r\n2nd place: $7.50\r\n3rd place: $5.00\r\n\r\n**The Fastest First-Time Competitor in 3x3x3 Cube at this competition will be provided a $10.00 gift card from Cubing Out Loud!**',
            display_order: 1,
          },
          {
            id: 29244,
            competition_id: 'PickeringFavouritesAutumn2023',
            name: 'Parking, Transit and Food',
            content:
              '## Food\r\n\r\nThere are several restaurants within a 10-minute walk from the venue including the [Pickering Town Centre](https://www.pickeringtowncentre.com/) food court.\r\n\r\n**There is no dedicated lunch break during the competition.** Please plan to grab lunch during a time when you are not competing.\r\n\r\n## Parking and Transit\r\n\r\nParking is free at the venue. The main entrance to the Recreation Complex is the closest to the Banquet Halls, which are located on the ground level.\r\n\r\nThe venue is a 20-minute walk or 10-minute bus ride from [Pickering GO Station](https://goo.gl/maps/tbFooorJmCJUTfcU8).\r\n\r\n',
            display_order: 2,
          },
          {
            id: 29245,
            competition_id: 'PickeringFavouritesAutumn2023',
            name: 'FAQ',
            content:
              '### What is a competition series?\r\n\r\nWhen two or more competitions are in a "series", it means that you can compete in ***one*** of the competitions in that series. This allows more competitors the opprotunity to compete at WCA competitions in the Greater Toronto Area.\r\n\r\nFor this series, you can compete in Pickering Favourites Autumn 2023 *or* Waterloo Favourites Autumn 2023, but not both.\r\n\r\n### When should I arrive at the venue?\r\n\r\nPlease plan to arrive about **30 minutes before the start of your first event**. If you are not competing in events during the morning, you do not need to be present until the afternoon. For example, if your first event of the day is 3x3x3 Cube, which starts at 1:45 PM, we would recommend arriving around 1:15 PM.\r\n\r\nPlease see the full schedule [here](https://www.worldcubeassociation.org/competitions/PickeringFavouritesAutumn2023#competition-schedule) (note: the schedule is subject to change depending on how many competitors register for each event).\r\n\r\n### Where do I check-in?\r\n\r\nCompetitors can pick up their name tag at check-in desk near the main entrance of the banquet hall.\r\n\r\nIf the check-in desk is closed when you arrive, please go to the data entry desk near the back of the banquet hall, behind the solving stations.\r\n\r\n### What should I expect at my first competition?\r\n\r\nPlease watch these short videos:\r\n\r\nyoutube(https://www.youtube.com/watch?v=xK2ycvTfgUY)\r\n\r\nyoutube(https://www.youtube.com/watch?v=vz1V0Gv0qX0)\r\n',
            display_order: 3,
          },
        ],
        'class': 'competition',
      }
    else
      CompetitionApi.find!(competition_id)
    end
  end
end
