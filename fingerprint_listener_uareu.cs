using System;
using System.Collections.Generic;
using System.Net;
using System.Text;
using System.Threading;
using System.Windows.Forms;
using DPUruNet;

class EmployeeTemplate
{
    public string ID                  { get; set; }
    public string IDCardNumber        { get; set; }
    public string FullName            { get; set; }
    public string FingerprintTemplate { get; set; } // base64(XML Fmd)
}

class FingerprintListenerUareU : Form
{
    const string SERVER_URL    = "http://localhost:8080";
    const int    RELOAD_MS     = 5 * 60 * 1000;  
    const int    POLL_MS       = 1500;          
    const int    THRESHOLD     = 0x7fffffff / 10000;  
    const int    RETRY_DELAY   = 2000;          

    Reader                 _reader;
    List<EmployeeTemplate> _templates = new List<EmployeeTemplate>();
    readonly object        _lock      = new object();
    bool                   _capturing = false;
    bool                   _polling   = true;
    System.Timers.Timer    _hideTimer    = null;
    System.Timers.Timer    _cancelTimer  = null;  
    volatile bool          _cancelled    = false; 

    string _currentPurpose    = ""; 
    string _currentEmployeeID = "";

    Label      _lblStatus;
    Label      _lblCount;
    Button     _btnReload;
    NotifyIcon _trayIcon;

    [STAThread]
    static void Main()
    {
        EnsureAutoStartRegistered();
        Application.Run(new FingerprintListenerUareU());
    }

    
    static void EnsureAutoStartRegistered()
    {
        try
        {
            string exePath = Application.ExecutablePath;
            using (var key = Microsoft.Win32.Registry.CurrentUser.OpenSubKey(
                @"Software\Microsoft\Windows\CurrentVersion\Run", true))
            {
                if (key == null) return;
                object existing = key.GetValue("FingerprintListenerUareU");
                if (existing == null || existing.ToString() != exePath)
                    key.SetValue("FingerprintListenerUareU", exePath);
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine("[!] Gagal daftar auto-start: " + ex.Message);
        }
    }

    public FingerprintListenerUareU()
    {
        Text            = "Fingerprint Listener — U.are.U 4500";
        Width           = 420;
        Height          = 180;
        FormBorderStyle = FormBorderStyle.FixedSingle;
        MaximizeBox     = false;
        ShowInTaskbar   = false;
        StartPosition   = FormStartPosition.CenterScreen;

        _lblStatus = new Label { Text = "Siap (idle)", Left = 12, Top = 12, Width = 390, Height = 20 };
        _lblCount  = new Label { Text = "",            Left = 12, Top = 38, Width = 390, Height = 20 };
        _btnReload = new Button {
            Text = "Reload Template", Left = 12, Top = 70, Width = 140, Height = 30
        };
        _btnReload.Click += (s, e) => ThreadPool.QueueUserWorkItem(_ => LoadTemplates());

        Controls.Add(_lblStatus);
        Controls.Add(_lblCount);
        Controls.Add(_btnReload);

        _trayIcon = new NotifyIcon();
        _trayIcon.Icon    = System.Drawing.SystemIcons.Information;
        _trayIcon.Text    = "Fingerprint Listener (idle) — klik 2x untuk buka";
        _trayIcon.Visible = true;
        _trayIcon.DoubleClick += (s, e) => ShowNormal();

        var menu = new ContextMenuStrip();
        menu.Items.Add("Buka Jendela", null, (s, e) => ShowNormal());
        menu.Items.Add("Reload Template", null, (s, e) => ThreadPool.QueueUserWorkItem(_ => LoadTemplates()));
        menu.Items.Add("-");
        menu.Items.Add("Keluar", null, (s, e) => { _trayIcon.Visible = false; Application.Exit(); });
        _trayIcon.ContextMenuStrip = menu;

        this.FormClosing += (s, e) => {
            if (e.CloseReason == CloseReason.UserClosing)
            {
                e.Cancel = true;
                HideToTray();
            }
        };
        // ──────────────────────────────────────────────────────────────────────

        Load       += OnLoad;
        FormClosed += OnClose;
    }

    void ShowNormal()
    {
        Show();
        WindowState   = FormWindowState.Normal;
        ShowInTaskbar = true;
        Activate();
    }

    void HideToTray()
    {
        Hide();
        ShowInTaskbar = false;
    }

    void OnLoad(object sender, EventArgs e)
    {
        // Idle dulu di tray — window TIDAK perlu visible terus karena
        // kita TIDAK langsung capture. Reader baru dibuka saat ada
        // permintaan scan aktif, dan saat itu window otomatis dimunculkan.
        HideToTray();

        ThreadPool.QueueUserWorkItem(_ => {
            LoadTemplates();
            ScheduleReload();
            StartPolling();
        });
    }

    // ── Template Loading ──────────────────────────────────────────────────

    void LoadTemplates()
    {
        SetStatus("Memuat template dari server...");
        try
        {
            var wc = new WebClient { Encoding = Encoding.UTF8 };
            string json = wc.DownloadString(SERVER_URL + "/api/fingerprint/templates");

            var loaded = ParseTemplateJson(json);
            lock (_lock) { _templates = loaded; }

            SetCount(string.Format("{0} template dimuat", loaded.Count));
            SetStatus("Siap (idle) — menunggu permintaan scan");
            SetTrayText(string.Format("Fingerprint Listener — {0} karyawan, idle", loaded.Count));
            Log("Template loaded: " + loaded.Count);
        }
        catch (Exception ex)
        {
            SetStatus("Gagal load template — server mati?");
            Log("[!] LoadTemplates error: " + ex.Message);
        }
    }

    List<EmployeeTemplate> ParseTemplateJson(string json)
    {
        var result = new List<EmployeeTemplate>();
        json = json.Trim();
        if (json == "[]" || json.Length < 5) return result;

        string[] parts = json.Split(new string[] { "},{" }, StringSplitOptions.None);
        foreach (string part in parts)
        {
            string obj = part.Replace("[", "").Replace("]", "")
                             .Replace("{", "").Replace("}", "").Trim();

            string id       = ExtractJsonInt(obj, "ID");
            string idCard   = ExtractJsonString(obj, "IDCardNumber");
            string fullName = ExtractJsonString(obj, "FullName");
            string tmpl     = ExtractJsonString(obj, "FingerprintTemplate");

            if (string.IsNullOrEmpty(idCard) || string.IsNullOrEmpty(tmpl)) continue;

            result.Add(new EmployeeTemplate {
                ID                  = id,
                IDCardNumber        = idCard,
                FullName            = fullName,
                FingerprintTemplate = tmpl,
            });
        }
        return result;
    }

    string ExtractJsonString(string obj, string key)
    {
        string search = "\"" + key + "\":\"";
        int start = obj.IndexOf(search, StringComparison.Ordinal);
        if (start < 0) return "";
        start += search.Length;
        int end = obj.IndexOf("\"", start);
        if (end < 0) return "";
        return obj.Substring(start, end - start);
    }

    string ExtractJsonInt(string obj, string key)
    {
        string search = "\"" + key + "\":";
        int start = obj.IndexOf(search, StringComparison.Ordinal);
        if (start < 0) return "";
        start += search.Length;
        int end = obj.IndexOf(",", start);
        if (end < 0) end = obj.Length;
        return obj.Substring(start, end - start).Replace("}", "").Replace("]", "").Trim();
    }

    void ScheduleReload()
    {
        var t = new System.Timers.Timer(RELOAD_MS);
        t.Elapsed += (s, e) => LoadTemplates();
        t.AutoReset = true;
        t.Start();
    }

    // ── Polling scan-status ──────────────────────────────────────────────

    void StartPolling()
    {
        while (_polling)
        {
            try
            {
                if (!_capturing)
                {
                    CheckScanStatus();
                }
            }
            catch (Exception ex)
            {
                Log("[!] Polling error: " + ex.Message);
            }
            Thread.Sleep(POLL_MS);
        }
    }

    void CheckScanStatus()
    {
        var wc = new WebClient { Encoding = Encoding.UTF8 };
        string json;
        try
        {
            json = wc.DownloadString(SERVER_URL + "/api/fingerprint/scan-status");
        }
        catch (Exception)
        {
            return;
        }
        bool active = json.IndexOf("\"active\":true", StringComparison.Ordinal) >= 0
                   || json.IndexOf("\"active\": true", StringComparison.Ordinal) >= 0;
        if (!active) return;

        string purpose    = ExtractJsonString(json.Replace("{", "").Replace("}", ""), "purpose");
        string employeeID = ExtractJsonString(json.Replace("{", "").Replace("}", ""), "employee_id");

        Log(string.Format("[*] Permintaan scan diterima: purpose={0} employee_id={1}", purpose, employeeID));

        _currentPurpose    = purpose;
        _currentEmployeeID = employeeID;

        ForceResetState();

        BeginInvokeIfNeeded(() => {
            ShowNormal();
            SetStatus("Menunggu sidik jari... (" + purpose + ")");
        });

        StartCaptureOnce();
    }

    void ForceResetState()
    {
        try { if (_reader != null) { _reader.Dispose(); _reader = null; } } catch { }
        _capturing = false;
        if (_hideTimer != null)
        {
            try { _hideTimer.Stop(); _hideTimer.Dispose(); } catch { }
            _hideTimer = null;
        }
    }


    void StartCaptureOnce()
    {
        if (_capturing) return;
        try
        {
            ReaderCollection readers = ReaderCollection.GetReaders();
            if (readers.Count == 0)
            {
                SetStatus("Device tidak terdeteksi — colokkan U.are.U 4500");
                Log("[!] Tidak ada reader");
                return; 
            }

            _reader = readers[0];
            _reader.Open(Constants.CapturePriority.DP_PRIORITY_COOPERATIVE);
            _reader.GetStatus();

            if (_reader.Status.Status == Constants.ReaderStatuses.DP_STATUS_NEED_CALIBRATION)
                _reader.Calibrate();

            _reader.On_Captured += OnCaptured;
            _reader.CaptureAsync(
                Constants.Formats.Fid.ANSI,
                Constants.CaptureProcessing.DP_IMG_PROC_DEFAULT,
                _reader.Capabilities.Resolutions[0]
            );

            _capturing = true;
            _cancelled = false;
            Log("[*] Reader aktif untuk 1x capture");
            StartCancelWatcher(); // mulai cek apakah browser cancel
        }
        catch (Exception ex)
        {
            _capturing = false;
            SetStatus("Error reader: " + ex.Message);
            Log("[!] StartCaptureOnce: " + ex.Message);
            CloseReaderAndReturnToIdle();
        }
    }

    // Cek setiap 1 detik apakah browser sudah kirim cancel.
    // Kalau ya, langsung tutup reader tanpa nunggu jari ditempel.
    void StartCancelWatcher()
    {
        if (_cancelTimer != null) { try { _cancelTimer.Stop(); _cancelTimer.Dispose(); } catch { } }
        _cancelTimer = new System.Timers.Timer(1000);
        _cancelTimer.AutoReset = true;
        _cancelTimer.Elapsed += (s, e) => {
            if (!_capturing) { // sudah selesai scan normal, stop watcher
                try { _cancelTimer.Stop(); } catch { }
                return;
            }
            try
            {
                var wc = new WebClient { Encoding = Encoding.UTF8 };
                string json = wc.DownloadString(SERVER_URL + "/api/fingerprint/scan-status");
                    
                bool serverCapturing = json.IndexOf("\"capturing\":true", StringComparison.Ordinal) >= 0
                                    || json.IndexOf("\"capturing\": true", StringComparison.Ordinal) >= 0;
                if (!serverCapturing && _capturing)
                {
                    Log("[*] Browser membatalkan scan — menutup reader");
                    _cancelled = true;
                    try { _cancelTimer.Stop(); } catch { }
                    CloseReaderAndReturnToIdle();
                    BeginInvokeIfNeeded(() => SetStatus("Scan dibatalkan"));
                }
            }
            catch { /* network error, coba lagi detik berikutnya */ }
        };
        _cancelTimer.Start();
    }

    void OnCaptured(CaptureResult result)
    {
        try
        {
            if (_cancelled) return;

            if (result.ResultCode != Constants.ResultCode.DP_SUCCESS || result.Data == null)
            {
                SetStatus("Gagal membaca sidik jari, coba lagi");
                return;
            }
            if (result.Quality != Constants.CaptureQuality.DP_QUALITY_GOOD)
            {
                Log("[~] Kualitas rendah: " + result.Quality);
                SetStatus("Kualitas scan rendah, coba lagi");
                return;
            }

            DataResult<Fmd> fmdResult = FeatureExtraction.CreateFmdFromFid(
                result.Data, Constants.Formats.Fmd.ANSI);

            if (fmdResult.ResultCode != Constants.ResultCode.DP_SUCCESS)
            {
                Log("[!] FeatureExtraction gagal: " + fmdResult.ResultCode);
                SetStatus("Gagal memproses sidik jari");
                return;
            }

            if (_currentPurpose == "enroll")
            {
                string duplicateName = null;
                string duplicateIDCard = null;

                List<EmployeeTemplate> snapshot;
                lock (_lock) { snapshot = new List<EmployeeTemplate>(_templates); }

                if (snapshot.Count > 0)
                {
                    var fmds = new Fmd[snapshot.Count];
                    var valid = new List<int>();
                    for (int i = 0; i < snapshot.Count; i++)
                    {
                        try
                        {
                            byte[] xmlBytes = Convert.FromBase64String(snapshot[i].FingerprintTemplate);
                            string xml = Encoding.UTF8.GetString(xmlBytes);
                            fmds[i] = Fmd.DeserializeXml(xml);
                            valid.Add(i);
                        }
                        catch { fmds[i] = null; }
                    }

                    if (valid.Count > 0)
                    {
                        var validFmds = new List<Fmd>();
                        var validIdxMap = new List<int>();
                        foreach (int i in valid)
                        {
                            if (fmds[i] != null) { validFmds.Add(fmds[i]); validIdxMap.Add(i); }
                        }

                        IdentifyResult identResult = Comparison.Identify(
                            fmdResult.Data, 0,
                            validFmds.ToArray(),
                            THRESHOLD,
                            validFmds.Count
                        );

                        if (identResult.ResultCode == Constants.ResultCode.DP_SUCCESS
                            && identResult.Indexes != null
                            && identResult.Indexes.Length > 0
                            && identResult.Indexes[0].Length > 0)
                        {
                            int matchPos = identResult.Indexes[0][0];
                            int empIdx = validIdxMap[matchPos];
                            var emp = snapshot[empIdx];

                            string cleanEmpID = (emp.ID ?? "").Trim();
                            string cleanCurrentID = (_currentEmployeeID ?? "").Trim();
                            if (cleanEmpID != cleanCurrentID)
                            {
                                duplicateName = emp.FullName;
                                duplicateIDCard = emp.IDCardNumber;
                            }
                        }
                    }
                }

                if (duplicateName != null)
                {
                    string errorMsg = string.Format("Sidik jari sudah terdaftar untuk {0} ({1})", duplicateName, duplicateIDCard);
                    Log("[!] GAGAL ENROLL: " + errorMsg);
                    SetStatus("Gagal enroll: sidik jari duplikat");
                    SendRawScan("", _currentEmployeeID, errorMsg);
                }
                else
                {
                    try
                    {
                        string xml = Fmd.SerializeXml(fmdResult.Data);
                        string base64Template = Convert.ToBase64String(Encoding.UTF8.GetBytes(xml));
                        SendRawScan(base64Template, _currentEmployeeID, "");
                        SetStatus("Template terkirim untuk pendaftaran");

                        // Muat ulang template agar sidik jari baru terdaftar langsung aktif secara biometrik
                        ThreadPool.QueueUserWorkItem(_ => LoadTemplates());
                    }
                    catch (Exception ex)
                    {
                        Log("[!] Gagal kirim raw scan: " + ex.Message);
                        SetStatus("Gagal mengirim template");
                    }
                }
            }
            else
            {
                // Mode identify — untuk form pengambilan
                string matchedIDCard = IdentifyFmd(fmdResult.Data);
                if (!string.IsNullOrEmpty(matchedIDCard))
                {
                    SendIdentify(matchedIDCard);
                }
                else
                {
                    Log("[-] Tidak dikenal");
                    SetStatus("Sidik jari tidak dikenal");
                    SendIdentify(""); // beri tahu server juga saat tidak match
                }
            }
        }
        catch (Exception ex)
        {
            Log("[!] OnCaptured: " + ex.Message);
        }
        finally
        {
            CloseReaderAndReturnToIdle();
        }
    }

    void CloseReaderAndReturnToIdle()
    {
        try { if (_reader != null) { _reader.Dispose(); _reader = null; } } catch { }
        _capturing = false;
        _currentPurpose = "";
        _currentEmployeeID = "";
        if (_cancelTimer != null) { try { _cancelTimer.Stop(); _cancelTimer.Dispose(); } catch { } _cancelTimer = null; }
        
        ThreadPool.QueueUserWorkItem(_ => {
            try {
                var wc = new WebClient();
                wc.Headers[HttpRequestHeader.ContentType] = "application/json";
                wc.UploadString(SERVER_URL + "/api/fingerprint/capture-done", "{}");
            } catch {  }
        });

        if (_hideTimer != null) { try { _hideTimer.Stop(); _hideTimer.Dispose(); } catch { } }
        _hideTimer = new System.Timers.Timer(2500);
        _hideTimer.AutoReset = false;
        _hideTimer.Elapsed += (s, e) => {
            BeginInvokeIfNeeded(() => {
                SetStatus("Siap (idle) — menunggu permintaan scan");
                HideToTray();
            });
        };
        _hideTimer.Start();
    }

    // ── FMD Matching ──────────────────────────────────────────────────────

    string IdentifyFmd(Fmd probe)
    {
        List<EmployeeTemplate> snapshot;
        lock (_lock) { snapshot = new List<EmployeeTemplate>(_templates); }

        if (snapshot.Count == 0)
        {
            Log("[!] Tidak ada template di memori");
            return null;
        }

        var fmds  = new Fmd[snapshot.Count];
        var valid = new List<int>();

        for (int i = 0; i < snapshot.Count; i++)
        {
            try
            {
                byte[] xmlBytes = Convert.FromBase64String(snapshot[i].FingerprintTemplate);
                string xml      = Encoding.UTF8.GetString(xmlBytes);
                fmds[i] = Fmd.DeserializeXml(xml);
                valid.Add(i);
            }
            catch (Exception ex)
            {
                Log("[!] Gagal deserialize FMD idx " + i + ": " + ex.Message);
                fmds[i] = null;
            }
        }

        if (valid.Count == 0) return null;

        var validFmds   = new List<Fmd>();
        var validIdxMap = new List<int>();
        foreach (int i in valid)
        {
            if (fmds[i] != null) { validFmds.Add(fmds[i]); validIdxMap.Add(i); }
        }

        IdentifyResult identResult = Comparison.Identify(
            probe, 0,
            validFmds.ToArray(),
            THRESHOLD,
            validFmds.Count
        );

        if (identResult.ResultCode == Constants.ResultCode.DP_SUCCESS
            && identResult.Indexes != null
            && identResult.Indexes.Length > 0
            && identResult.Indexes[0].Length > 0)
        {
            int matchPos = identResult.Indexes[0][0];
            int empIdx   = validIdxMap[matchPos];
            var emp      = snapshot[empIdx];

            Log(string.Format("[+] MATCH! {0} ({1})", emp.FullName, emp.IDCardNumber));
            SetStatus("Teridentifikasi: " + emp.FullName);
            return emp.IDCardNumber;
        }

        return null;
    }

    // ── Kirim hasil ke Go server ────────────────────────────────────────────

    void SendIdentify(string idCard)
    {
        try
        {
            var wc = new WebClient();
            wc.Headers[HttpRequestHeader.ContentType] = "application/json";
            string body = "{\"id_card\":\"" + EscapeJson(idCard) + "\"}";
            string resp = wc.UploadString(SERVER_URL + "/api/fingerprint/identify", body);
            Log("[+] Server response: " + resp);
        }
        catch (Exception ex)
        {
            Log("[!] SendIdentify error: " + ex.Message);
        }
    }

    void SendRawScan(string template, string employeeID, string errorMsg)
    {
        try
        {
            var wc = new WebClient();
            wc.Headers[HttpRequestHeader.ContentType] = "application/json";
            string body = "{\"template\":\"" + template + "\",\"employee_id\":\"" + EscapeJson(employeeID) + "\",\"error\":\"" + EscapeJson(errorMsg) + "\"}";
            string resp = wc.UploadString(SERVER_URL + "/api/fingerprint/register-scan", body);
            Log("[+] Raw scan terkirim ke server (employee_id=" + employeeID + ")");
        }
        catch (Exception ex)
        {
            Log("[!] SendRawScan error: " + ex.Message);
        }
    }

    string EscapeJson(string s)
    {
        return s.Replace("\\", "\\\\").Replace("\"", "\\\"");
    }

    // ── Helper ───────────────────────────────────────────────────────────

    void BeginInvokeIfNeeded(Action action)
    {
        if (IsHandleCreated)
            BeginInvoke(action);
    }

    void SetStatus(string msg)
    {
        BeginInvokeIfNeeded(() => _lblStatus.Text = msg);
    }

    void SetCount(string msg)
    {
        BeginInvokeIfNeeded(() => _lblCount.Text = msg);
    }

    void SetTrayText(string msg)
    {
        BeginInvokeIfNeeded(() => {
            if (_trayIcon != null) _trayIcon.Text = msg.Length > 63 ? msg.Substring(0, 63) : msg;
        });
    }

    void Log(string msg)
    {
        Console.WriteLine("[{0}] {1}", DateTime.Now.ToString("HH:mm:ss"), msg);
    }

    void OnClose(object sender, FormClosedEventArgs e)
    {
        _polling = false;
        try { if (_cancelTimer != null) { _cancelTimer.Stop(); _cancelTimer.Dispose(); } } catch { }
        try { if (_reader != null) _reader.Dispose(); } catch { }
        try { if (_trayIcon != null) { _trayIcon.Visible = false; _trayIcon.Dispose(); } } catch { }
    }
}
