# Политика конфиденциальности / Privacy Policy

**Приложение «Admity»**
**Дата вступления в силу: 2 июля 2026 года**

---

## РУССКИЙ ЯЗЫК

### 1. Кто мы

Admity — мобильное приложение для школьников Казахстана (8–12 классы), которое помогает подготовиться к поступлению в вузы. Приложение разработано и поддерживается индивидуальным разработчиком Нурланом Бейсенбаевым (далее — «мы», «разработчик»).

Идентификатор приложения: `kz.admity.app`
Контактный адрес: sanjariouslegendarious@gmail.com *(замените на официальный адрес поддержки перед публикацией)*

---

### 2. Какие данные мы собираем

#### 2.1 Данные аккаунта (только для зарегистрированных пользователей)

Если вы создаёте аккаунт, мы сохраняем:

- **Адрес электронной почты** — для входа в систему и идентификации вашего аккаунта.
- Если вы используете «Вход через Apple» — токен идентификации Apple; ваш настоящий email может быть скрыт (через функцию «Скрыть мой email» от Apple).

Гости (режим «Продолжить как гость») не предоставляют никаких данных аккаунта.

#### 2.2 Данные профиля (заполняются вами добровольно)

В процессе знакомства с приложением и редактирования профиля вы можете указать:

| Поле | Зачем нужно |
|------|------------|
| Имя (отображаемое) | Персонализация интерфейса (хранится только локально и, если вы вошли в систему, в вашем профиле на сервере) |
| Класс / год обучения | Подбор релевантного контента |
| Город / регион | Информация о местных мероприятиях |
| Средний балл (ГПА) | Оценка шансов поступления |
| Результаты экзаменов: IELTS, SAT, TOEFL | Подбор вузов и стипендий |
| Целевые направления и вузы | Персонализация рекомендаций |
| Интересы и предпочтения | Подбор курсов и профориентация |
| Расписание и ежедневная цель (минуты) | Составление плана подготовки |
| Возраст | Адаптация контента для целевой аудитории |
| Результат теста на профориентацию | Карьерные рекомендации |

Все поля **необязательны** — приложение работает без их заполнения.

#### 2.3 Сообщения в чате с ИИ-наставником Ералы

Текст сообщений, которые вы отправляете Ералы, временно передаётся на наш сервер для обработки. Подробнее — в разделе 4 «Обработка данных с помощью ИИ».

История чата хранится **только на вашем устройстве** (в локальной базе данных) и не синхронизируется с сервером.

#### 2.4 Прикреплённые документы

Файлы, которые вы прикрепляете в разделе «Документы» (транскрипты, письма и т. д.), сохраняются **исключительно на вашем устройстве** в папке с данными приложения. Эти файлы **никогда не загружаются** на наши серверы или серверы третьих лиц.

#### 2.5 Данные, которые мы НЕ собираем

Мы не собираем:

- Геолокацию в режиме реального времени (GPS).
- Контакты, фотографии, камеру или микрофон.
- Идентификаторы устройства для рекламных целей.
- Данные о просматриваемых страницах и поведении в интернете вне приложения.
- Аналитику через сторонние SDK (Google Analytics, Firebase Analytics, Meta и т. п.).

---

### 3. Как мы используем данные

Данные используются исключительно для следующих целей:

1. **Предоставление функций приложения** — вход в систему, синхронизация профиля между устройствами, персонализация рекомендаций по вузам и стипендиям.
2. **Работа ИИ-наставника Ералы** — передача вашего вопроса и минимального контекста профиля в языковую модель (см. раздел 4).
3. **Составление плана подготовки** — анализ вашего расписания и целей для формирования персонального плана.
4. **Локальные уведомления** — напоминания об учёбе, которые вы сами настраиваете. Мы не отправляем push-уведомления с сервера.

Мы **не используем** ваши данные для рекламы, не продаём их третьим лицам и не передаём их брокерам данных.

---

### 4. Обработка данных с помощью ИИ (Ералы)

Когда вы отправляете сообщение наставнику Ералы:

1. Ваше сообщение вместе с **минимальным контекстом профиля** передаётся на наш сервер (Supabase Edge Function, расположенный в ЕС/США).
2. С сервера запрос перенаправляется в **языковую модель Anthropic Claude** через API Anthropic.

**Что передаётся в языковую модель (минимизация персональных данных):**

- Текст вашего сообщения.
- Класс, возраст, роль (ученик/родитель), мотивация, интересы, целевые направления и вузы, расписание — если вы их указали.
- ГПА передаётся **только как диапазон** (например, «4.0–4.5»), а не точное число.
- Результаты IELTS, SAT, TOEFL (если указаны).

**Что НЕ передаётся в языковую модель:**

- Ваше имя.
- Адрес электронной почты.
- Город / регион.
- Прикреплённые файлы.

Anthropic является нашим **субпроцессором** (обработчиком данных) и обрабатывает данные в соответствии с [Политикой конфиденциальности Anthropic](https://www.anthropic.com/privacy). Ключ API хранится **только на сервере** и никогда не попадает в приложение.

Ералы не пишет эссе целиком и не выполняет за вас домашние задания — он направляет и помогает, но не делает работу вместо вас.

---

### 5. Хранение данных и безопасность

| Данные | Где хранятся | Шифрование |
|--------|-------------|------------|
| Профиль (зарегистрированные пользователи) | Локально (Hive) + Supabase (`app_profiles`) | На устройстве + TLS в транзите + шифрование Supabase в покое |
| Профиль (гости) | Только на устройстве (Hive) | Стандартная защита ОС |
| История чата | Только на устройстве | Стандартная защита ОС |
| Прикреплённые файлы | Только на устройстве | Стандартная защита ОС |
| Аккаунт (email) | Supabase Auth (ЕС/США) | TLS в транзите + шифрование в покое |

**Supabase** — облачный провайдер, предоставляющий базы данных Postgres с политиками Row Level Security (RLS): каждый пользователь может читать и изменять только свои собственные данные. Подробнее: [supabase.com/privacy](https://supabase.com/privacy).

Все соединения с сервером осуществляются по протоколу **HTTPS/TLS**.

---

### 6. Данные несовершеннолетних

Admity предназначен для пользователей **от 13 лет**. Мы намеренно собираем минимальный объём данных, учитывая, что основная аудитория — подростки.

- Мы не запрашиваем излишних персональных данных.
- Данные гостей хранятся только на устройстве — без передачи на серверы.
- Родители или законные представители могут запросить доступ к данным ребёнка или их удаление, написав на наш контактный адрес (раздел 11).

Если нам станет известно, что пользователю нет 13 лет, мы удалим его аккаунт и данные.

---

### 7. Ваши права

Вы можете в любое время:

- **Просмотреть данные** — все данные профиля отображаются прямо в приложении.
- **Изменить данные** — в разделе «Профиль».
- **Удалить данные** — в разделе «Профиль» → «Удалить аккаунт» (данные на сервере удаляются); или напишите нам на контактный адрес.
- **Запросить экспорт** — обратитесь к нам по электронной почте.
- **Удалить приложение** — все локальные данные (включая файлы) автоматически удаляются вместе с приложением.

Для запросов, связанных с данными, пишите на: sanjariouslegendarious@gmail.com *(замените перед публикацией)*

Мы отвечаем в течение 30 дней.

---

### 8. Срок хранения данных

- **Данные аккаунта и профиля** хранятся, пока существует аккаунт. После удаления аккаунта данные на сервере удаляются в течение 30 дней.
- **Локальные данные** (Hive, файлы) хранятся на устройстве до удаления приложения или ручной очистки.
- **Сообщения, переданные в ИИ**, не сохраняются нами после получения ответа.

---

### 9. Реклама и передача данных третьим лицам

- Мы **не показываем рекламу** и не используем рекламные SDK.
- Мы **не продаём** ваши данные.
- Мы **не передаём** данные третьим лицам, кроме Supabase (хостинг и база данных) и Anthropic (языковая модель — только при обращении к Ералы), описанных выше.

---

### 10. Уведомления

Admity использует только **локальные уведомления** (напоминания об учёбе), которые генерируются на вашем устройстве. Мы не используем push-уведомления с сервера и не передаём токены устройств каким-либо сторонним сервисам.

---

### 11. Изменения политики

При существенных изменениях в политике мы уведомим вас через обновление в приложении или по электронной почте (если она у нас есть). Продолжение использования приложения после обновления означает согласие с новой редакцией.

---

### 12. Контакты

По вопросам конфиденциальности обращайтесь:

**Email:** sanjariouslegendarious@gmail.com *(замените на официальный адрес поддержки)*
**Разработчик:** Нурлан Бейсенбаев

---
---

## ENGLISH

# Privacy Policy — Admity

**Effective date: July 2, 2026**

### 1. Who We Are

Admity is a mobile application for Kazakhstan schoolchildren (grades 8–12) that helps them prepare for university admission. The application is developed and maintained by an individual developer, Nurlan Beisenbayev (referred to as "we" or "developer").

App bundle ID: `kz.admity.app`
Contact: sanjariouslegendarious@gmail.com *(replace with official support address before publishing)*

---

### 2. Data We Collect

#### 2.1 Account Data (signed-in users only)

If you create an account, we store:

- **Email address** — to sign you in and identify your account.
- If you use Sign in with Apple — an Apple identity token; your real email may be hidden via Apple's "Hide My Email" feature.

Guests (those who choose "Continue as Guest") provide no account data.

#### 2.2 Profile Data (provided voluntarily by you)

During onboarding and profile editing, you may provide:

| Field | Purpose |
|-------|---------|
| Display name | Interface personalisation (stored locally and, if signed in, in your server profile) |
| Grade / year | Relevant content selection |
| City / region | Local event information |
| GPA | Admission-chance estimation |
| Exam scores: IELTS, SAT, TOEFL | University and scholarship matching |
| Target majors and universities | Personalised recommendations |
| Interests and preferences | Course selection and career guidance |
| Schedule and daily goal (minutes) | Study plan creation |
| Age | Content adaptation for the target audience |
| Career test result | Career recommendations |

All fields are **optional** — the app works without them.

#### 2.3 Chat Messages to AI Mentor Eraly

The text of messages you send to Eraly is temporarily transmitted to our server for processing. See Section 4 ("AI Processing") for details.

Chat history is stored **on your device only** (in a local database) and is not synced to the server.

#### 2.4 Attached Documents

Files you attach in the Documents section (transcripts, letters, etc.) are saved **exclusively on your device** in the app's data folder. These files are **never uploaded** to our servers or any third party.

#### 2.5 Data We Do NOT Collect

We do not collect:

- Real-time location (GPS).
- Contacts, photos, camera, or microphone.
- Device identifiers for advertising purposes.
- Web browsing history or behaviour outside the app.
- Analytics via third-party SDKs (Google Analytics, Firebase Analytics, Meta, etc.).

---

### 3. How We Use Data

Data is used solely for the following purposes:

1. **App functionality** — sign-in, profile sync across devices, personalised university and scholarship recommendations.
2. **AI mentor Eraly** — forwarding your question and a minimal profile context to the language model (see Section 4).
3. **Study plan creation** — analysing your schedule and goals to build a personalised study plan.
4. **Local notifications** — study reminders that you configure yourself. We do not send server-side push notifications.

We do **not** use your data for advertising, do not sell it to third parties, and do not share it with data brokers.

---

### 4. AI Processing (Eraly)

When you send a message to Eraly:

1. Your message, along with a **minimal profile context**, is sent to our server (Supabase Edge Function, hosted in the EU/US).
2. The server forwards the request to the **Anthropic Claude language model** via the Anthropic API.

**What is sent to the language model (data minimisation):**

- The text of your message.
- Grade, age, role (student/parent), motivation, interests, target majors and universities, schedule — if you provided them.
- GPA is sent only as a **band** (e.g., "4.0–4.5"), never as an exact number.
- IELTS, SAT, TOEFL scores (if provided).

**What is NOT sent to the language model:**

- Your name.
- Your email address.
- Your city / region.
- Attached files.

Anthropic acts as our **sub-processor** and handles data in accordance with the [Anthropic Privacy Policy](https://www.anthropic.com/privacy). The API key is stored **server-side only** and is never embedded in the app.

Eraly does not write essays in full or do homework on your behalf — it guides and coaches, but does not do the work for you.

---

### 5. Storage and Security

| Data | Where stored | Encryption |
|------|-------------|------------|
| Profile (signed-in users) | Locally (Hive) + Supabase (`app_profiles`) | On-device + TLS in transit + Supabase encryption at rest |
| Profile (guests) | On-device only (Hive) | Standard OS protection |
| Chat history | On-device only | Standard OS protection |
| Attached files | On-device only | Standard OS protection |
| Account (email) | Supabase Auth (EU/US) | TLS in transit + encryption at rest |

**Supabase** is our cloud hosting provider. It uses Postgres with Row Level Security (RLS) policies, ensuring each user can only read and modify their own data. For more, see [supabase.com/privacy](https://supabase.com/privacy).

All connections to our server use **HTTPS/TLS**.

---

### 6. Children's Privacy

Admity is intended for users **aged 13 and older**. We deliberately collect minimal data, given that our primary audience is teenagers.

- We do not request unnecessary personal information.
- Guest data remains on-device only — nothing is transmitted to servers.
- Parents or legal guardians may request access to or deletion of a child's data by contacting us (Section 11).

If we become aware that a user is under 13, we will delete their account and data.

---

### 7. Your Rights

At any time, you may:

- **View your data** — all profile data is visible directly in the app.
- **Edit your data** — in the Profile section.
- **Delete your data** — via Profile → Delete Account (server data is removed); or contact us by email.
- **Request an export** — email us.
- **Uninstall the app** — all local data (including files) is automatically removed.

To make a data request, email: sanjariouslegendarious@gmail.com *(replace before publishing)*

We respond within 30 days.

---

### 8. Data Retention

- **Account and profile data** is retained while the account exists. After account deletion, server data is removed within 30 days.
- **Local data** (Hive, files) is retained on-device until the app is uninstalled or manually cleared.
- **Messages sent to the AI** are not stored by us after the response is delivered.

---

### 9. Advertising and Third-Party Sharing

- We do **not show ads** and use no advertising SDKs.
- We do **not sell** your data.
- We do **not share** data with third parties other than Supabase (hosting and database) and Anthropic (language model — only when you use Eraly), as described above.

---

### 10. Notifications

Admity uses only **local notifications** (study reminders) generated on your device. We do not use server-side push notifications and do not transmit device tokens to any third-party service.

---

### 11. Changes to This Policy

For material changes to this policy, we will notify you via an in-app notice or by email (if we have it). Continued use of the app after an update constitutes acceptance of the revised policy.

---

### 12. Contact

For privacy inquiries:

**Email:** sanjariouslegendarious@gmail.com *(replace with official support address)*
**Developer:** Nurlan Beisenbayev
