# Windows PowerShell WPF - PC PowerSaver Pro
# UTF-8 Encoding

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Windows.Forms, System.Drawing

# Win32 API Definitions for Display, Idle Time, Execution State
$Win32Code = @"
using System;
using System.Runtime.InteropServices;

public class Win32Power {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool GetLastInputInfo(ref LASTINPUTINFO plii);

    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern IntPtr SendMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);

    [DllImport("kernel32.dll")]
    public static extern uint SetThreadExecutionState(uint esFlags);

    public const uint ES_CONTINUOUS = 0x80000000;
    public const uint ES_SYSTEM_REQUIRED = 0x00000001;
    public const uint ES_DISPLAY_REQUIRED = 0x00000002;

    public const uint WM_SYSCOMMAND = 0x0112;
    public const int SC_MONITORPOWER = 0xF170;

    [StructLayout(LayoutKind.Sequential)]
    public struct LASTINPUTINFO {
        public uint cbSize;
        public uint dwTime;
    }

    public static uint GetIdleTimeSeconds() {
        LASTINPUTINFO lastInput = new LASTINPUTINFO();
        lastInput.cbSize = (uint)Marshal.SizeOf(lastInput);
        if (GetLastInputInfo(ref lastInput)) {
            uint idleMs = (uint)Environment.TickCount - lastInput.dwTime;
            return idleMs / 1000;
        }
        return 0;
    }

    public static void TurnOffDisplay() {
        SendMessage((IntPtr)0xFFFF, WM_SYSCOMMAND, (IntPtr)SC_MONITORPOWER, (IntPtr)2);
    }

    public static void SetKeepAwake(bool enable) {
        if (enable) {
            SetThreadExecutionState(ES_CONTINUOUS | ES_SYSTEM_REQUIRED | ES_DISPLAY_REQUIRED);
        } else {
            SetThreadExecutionState(ES_CONTINUOUS);
        }
    }
}
"@

Add-Type -TypeDefinition $Win32Code -ErrorAction SilentlyContinue

# XAML GUI Design
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="PC PowerSaver Pro" Height="680" Width="900"
        WindowStartupLocation="CenterScreen" WindowStyle="None" AllowsTransparency="True"
        Background="Transparent">
    
    <Window.Resources>
        <Style TargetType="Button">
            <Setter Property="Background" Value="#2A2F3D"/>
            <Setter Property="Foreground" Value="#E0E6ED"/>
            <Setter Property="FontSize" Value="14"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Padding" Value="12,8"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border" Background="{TemplateBinding Background}" CornerRadius="8" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#3B4254"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#1E222D"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>

    <Border Background="#131722" CornerRadius="16" BorderBrush="#2A3042" BorderThickness="1">
        <Grid>
            <Grid.RowDefinitions>
                <RowDefinition Height="50"/>
                <RowDefinition Height="*"/>
                <RowDefinition Height="60"/>
            </Grid.RowDefinitions>

            <!-- Header Bar -->
            <Border Grid.Row="0" Background="#1C2130" CornerRadius="16,16,0,0" x:Name="HeaderBar">
                <Grid Margin="20,0">
                    <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                        <TextBlock Text="⚡ PC PowerSaver Pro" Foreground="#00F2FE" FontSize="18" FontWeight="Bold"/>
                        <TextBlock Text="v1.0" Foreground="#6C7A9C" FontSize="12" Margin="10,4,0,0"/>
                    </StackPanel>
                    <StackPanel Orientation="Horizontal" HorizontalAlignment="Right" VerticalAlignment="Center">
                        <Button x:Name="BtnMinimize" Content="─" Width="36" Height="30" Background="Transparent" Foreground="#A0AEC0" Margin="0,0,4,0"/>
                        <Button x:Name="BtnClose" Content="✕" Width="36" Height="30" Background="Transparent" Foreground="#FF6B6B"/>
                    </StackPanel>
                </Grid>
            </Border>

            <!-- Main Content Area -->
            <Grid Grid.Row="1" Margin="20">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="220"/>
                    <ColumnDefinition Width="*"/>
                </Grid.ColumnDefinitions>

                <!-- Left Navigation -->
                <StackPanel Grid.Column="0" Margin="0,0,15,0">
                    <Button x:Name="NavTimer" Content="⏱️ 타이머 설정" Margin="0,0,0,8" HorizontalAlignment="Stretch" HorizontalContentAlignment="Left" Background="#00F2FE" Foreground="#0F172A"/>
                    <Button x:Name="NavIdle" Content="💤 부재 감지 절전" Margin="0,0,0,8" HorizontalAlignment="Stretch" HorizontalContentAlignment="Left"/>
                    <Button x:Name="NavSchedule" Content="⏰ 예약 시간 절전" Margin="0,0,0,8" HorizontalAlignment="Stretch" HorizontalContentAlignment="Left"/>
                    <Button x:Name="NavPowerPlan" Content="🔋 전원 플랜 관리" Margin="0,0,0,8" HorizontalAlignment="Stretch" HorizontalContentAlignment="Left"/>
                    
                    <Border Background="#1C2130" CornerRadius="10" Padding="12" Margin="0,20,0,0">
                        <StackPanel>
                            <TextBlock Text="💡 빠른 실행" Foreground="#94A3B8" FontSize="12" FontWeight="Bold" Margin="0,0,0,10"/>
                            <Button x:Name="BtnQuickScreenOff" Content="🖥️ 즉시 화면 끄기" Margin="0,0,0,6" Height="34" FontSize="12"/>
                            <Button x:Name="BtnQuickSleep" Content="🌙 즉시 절전 모드" Margin="0,0,0,6" Height="34" FontSize="12"/>
                            <Button x:Name="BtnCaffeineToggle" Content="☕ 카페인 모드: OFF" Height="34" FontSize="12" Background="#334155"/>
                        </StackPanel>
                    </Border>
                </StackPanel>

                <!-- Right View Panel -->
                <Border Grid.Column="1" Background="#1C2130" CornerRadius="12" Padding="24">
                    <Grid>
                        <!-- PANEL 1: Timer -->
                        <Grid x:Name="PanelTimer" Visibility="Visible">
                            <StackPanel>
                                <TextBlock Text="⏱️ 카운트다운 타이머 절전" Foreground="#F8FAFC" FontSize="20" FontWeight="Bold"/>
                                <TextBlock Text="지정한 시간이 지나면 지정한 전원 동작(절전/종료 등)을 자동으로 실행합니다." Foreground="#94A3B8" FontSize="13" Margin="0,4,0,20"/>

                                <TextBlock Text="빠른 시간 선택" Foreground="#CBD5E1" FontSize="14" FontWeight="SemiBold" Margin="0,0,0,8"/>
                                <WrapPanel Margin="0,0,0,20">
                                    <Button x:Name="BtnPreset15" Content="15분" Width="80" Margin="0,0,8,8"/>
                                    <Button x:Name="BtnPreset30" Content="30분" Width="80" Margin="0,0,8,8"/>
                                    <Button x:Name="BtnPreset60" Content="1시간" Width="80" Margin="0,0,8,8"/>
                                    <Button x:Name="BtnPreset120" Content="2시간" Width="80" Margin="0,0,8,8"/>
                                </WrapPanel>

                                <Grid Margin="0,0,0,20">
                                    <Grid.ColumnDefinitions>
                                        <ColumnDefinition Width="*"/>
                                        <ColumnDefinition Width="150"/>
                                    </Grid.ColumnDefinitions>
                                    <StackPanel Grid.Column="0">
                                        <TextBlock Text="사용자 지정 (분)" Foreground="#CBD5E1" FontSize="14" FontWeight="SemiBold"/>
                                        <Slider x:Name="SliderTimerMinutes" Minimum="1" Maximum="300" Value="30" TickFrequency="5" IsSnapToTickEnabled="True" Margin="0,10,15,0"/>
                                    </StackPanel>
                                    <TextBox x:Name="TxtTimerMinutes" Grid.Column="1" Text="30" FontSize="20" FontWeight="Bold" Foreground="#00F2FE" Background="#0F172A" BorderThickness="1" BorderBrush="#334155" VerticalContentAlignment="Center" HorizontalContentAlignment="Center" Height="45"/>
                                </Grid>

                                <TextBlock Text="수행할 동작 선택" Foreground="#FFFFFF" FontSize="14" FontWeight="Bold" Margin="0,0,0,8"/>
                                <ComboBox x:Name="CmbTimerAction" Height="40" Background="#F1F5F9" Foreground="#000000" FontSize="14" FontWeight="SemiBold" VerticalContentAlignment="Center" Margin="0,0,0,25">
                                    <ComboBoxItem Content="🌙 절전 모드 (Sleep)" Foreground="#000000" IsSelected="True"/>
                                    <ComboBoxItem Content="💤 최대 절전 모드 (Hibernate)" Foreground="#000000"/>
                                    <ComboBoxItem Content="🖥️ 화면만 끄기 (Screen Off)" Foreground="#000000"/>
                                    <ComboBoxItem Content="🔌 PC 완전 종료 (Shutdown)" Foreground="#000000"/>
                                    <ComboBoxItem Content="🔄 PC 다시 시작 (Restart)" Foreground="#000000"/>
                                </ComboBox>

                                <Border Background="#0F172A" CornerRadius="10" Padding="15" Margin="0,0,0,20">
                                    <StackPanel HorizontalAlignment="Center">
                                        <TextBlock x:Name="TxtTimerStatus" Text="남은 시간: 대기 중" Foreground="#00F2FE" FontSize="24" FontWeight="Bold" HorizontalAlignment="Center"/>
                                        <ProgressBar x:Name="ProgressTimer" Height="8" Width="400" Margin="0,10,0,0" Background="#1E293B" Foreground="#00F2FE" Minimum="0" Maximum="100" Value="0"/>
                                    </StackPanel>
                                </Border>

                                <StackPanel Orientation="Horizontal" HorizontalAlignment="Center">
                                    <Button x:Name="BtnStartTimer" Content="▶️ 타이머 시작" Width="160" Height="45" Background="#00F2FE" Foreground="#0F172A" FontSize="16" Margin="0,0,10,0"/>
                                    <Button x:Name="BtnCancelTimer" Content="⏹️ 취소" Width="120" Height="45" Background="#EF4444" Foreground="#FFFFFF" FontSize="16" IsEnabled="False"/>
                                </StackPanel>
                            </StackPanel>
                        </Grid>

                        <!-- PANEL 2: Idle Detection -->
                        <Grid x:Name="PanelIdle" Visibility="Collapsed">
                            <StackPanel>
                                <TextBlock Text="💤 부재(Idle) 감지 자동 절전" Foreground="#F8FAFC" FontSize="20" FontWeight="Bold"/>
                                <TextBlock Text="키보드/마우스 입력이 일정 시간 동안 없을 경우 자동으로 절전 상태로 전환합니다." Foreground="#94A3B8" FontSize="13" Margin="0,4,0,20"/>

                                <CheckBox x:Name="ChkEnableIdle" Content="부재 감지 기능 활성화" Foreground="#00F2FE" FontSize="16" FontWeight="Bold" Margin="0,0,0,20"/>

                                <TextBlock Text="부재 임계 시간 (분)" Foreground="#CBD5E1" FontSize="14" FontWeight="SemiBold"/>
                                <Grid Margin="0,5,0,20">
                                    <Grid.ColumnDefinitions>
                                        <ColumnDefinition Width="*"/>
                                        <ColumnDefinition Width="100"/>
                                    </Grid.ColumnDefinitions>
                                    <Slider x:Name="SliderIdleMinutes" Minimum="1" Maximum="120" Value="10" TickFrequency="1" IsSnapToTickEnabled="True" Margin="0,10,15,0"/>
                                    <TextBlock x:Name="TxtIdleMinutes" Grid.Column="1" Text="10 분" FontSize="18" FontWeight="Bold" Foreground="#00F2FE" VerticalAlignment="Center" HorizontalAlignment="Center"/>
                                </Grid>

                                <TextBlock Text="부재 시 실행할 동작" Foreground="#FFFFFF" FontSize="14" FontWeight="Bold" Margin="0,0,0,8"/>
                                <ComboBox x:Name="CmbIdleAction" Height="40" Background="#F1F5F9" Foreground="#000000" FontSize="14" FontWeight="SemiBold" VerticalContentAlignment="Center" Margin="0,0,0,25">
                                    <ComboBoxItem Content="🌙 절전 모드 (Sleep)" Foreground="#000000" IsSelected="True"/>
                                    <ComboBoxItem Content="🖥️ 화면 끄기 (Screen Off)" Foreground="#000000"/>
                                    <ComboBoxItem Content="💤 최대 절전 모드 (Hibernate)" Foreground="#000000"/>
                                </ComboBox>

                                <Border Background="#0F172A" CornerRadius="10" Padding="15">
                                    <StackPanel>
                                        <TextBlock x:Name="TxtCurrentIdleTime" Text="현재 부재 시간: 0초" Foreground="#94A3B8" FontSize="16" HorizontalAlignment="Center"/>
                                        <TextBlock Text="💡 컴퓨터 사용을 멈추면 타임아웃 카운트가 시작됩니다." Foreground="#64748B" FontSize="12" HorizontalAlignment="Center" Margin="0,4,0,0"/>
                                    </StackPanel>
                                </Border>
                            </StackPanel>
                        </Grid>

                        <!-- PANEL 3: Schedule -->
                        <Grid x:Name="PanelSchedule" Visibility="Collapsed">
                            <StackPanel>
                                <TextBlock Text="⏰ 예약 시간 절전 및 종료 (2개 예약 설정)" Foreground="#F8FAFC" FontSize="20" FontWeight="Bold"/>
                                <TextBlock Text="매일 지정한 시각에 자동으로 절전/종료를 수행합니다. (최대 2개 예약 지원)" Foreground="#94A3B8" FontSize="13" Margin="0,4,0,15"/>

                                <!-- Schedule 1 Box -->
                                <Border Background="#0F172A" CornerRadius="10" Padding="15" Margin="0,0,0,12" BorderBrush="#334155" BorderThickness="1">
                                    <StackPanel>
                                        <Grid Margin="0,0,0,10">
                                            <CheckBox x:Name="ChkEnableSchedule1" Content="📌 예약 1 활성화" Foreground="#00F2FE" FontSize="15" FontWeight="Bold"/>
                                            <TextBlock x:Name="TxtScheduleStatus1" Text="대기 중" Foreground="#94A3B8" FontSize="13" HorizontalAlignment="Right"/>
                                        </Grid>
                                        <Grid>
                                            <Grid.ColumnDefinitions>
                                                <ColumnDefinition Width="140"/>
                                                <ColumnDefinition Width="*"/>
                                            </Grid.ColumnDefinitions>
                                            <StackPanel Grid.Column="0" Orientation="Horizontal" VerticalAlignment="Center">
                                                <TextBox x:Name="TxtSchedHour1" Text="12" Width="45" Height="36" FontSize="16" FontWeight="Bold" Foreground="#00F2FE" Background="#1C2130" BorderBrush="#334155" HorizontalContentAlignment="Center" VerticalContentAlignment="Center"/>
                                                <TextBlock Text=":" Foreground="#FFFFFF" FontSize="18" FontWeight="Bold" Margin="6,3"/>
                                                <TextBox x:Name="TxtSchedMin1" Text="30" Width="45" Height="36" FontSize="16" FontWeight="Bold" Foreground="#00F2FE" Background="#1C2130" BorderBrush="#334155" HorizontalContentAlignment="Center" VerticalContentAlignment="Center"/>
                                            </StackPanel>
                                            <ComboBox x:Name="CmbSchedAction1" Grid.Column="1" Height="36" Background="#F1F5F9" Foreground="#000000" FontSize="13" FontWeight="SemiBold" VerticalContentAlignment="Center">
                                                <ComboBoxItem Content="🌙 절전 모드 (Sleep)" Foreground="#000000" IsSelected="True"/>
                                                <ComboBoxItem Content="💤 최대 절전 모드 (Hibernate)" Foreground="#000000"/>
                                                <ComboBoxItem Content="🖥️ 화면만 끄기 (Screen Off)" Foreground="#000000"/>
                                                <ComboBoxItem Content="🔌 PC 완전 종료 (Shutdown)" Foreground="#000000"/>
                                                <ComboBoxItem Content="🔄 PC 다시 시작 (Restart)" Foreground="#000000"/>
                                            </ComboBox>
                                        </Grid>
                                    </StackPanel>
                                </Border>

                                <!-- Schedule 2 Box -->
                                <Border Background="#0F172A" CornerRadius="10" Padding="15" Margin="0,0,0,12" BorderBrush="#334155" BorderThickness="1">
                                    <StackPanel>
                                        <Grid Margin="0,0,0,10">
                                            <CheckBox x:Name="ChkEnableSchedule2" Content="📌 예약 2 활성화" Foreground="#00F2FE" FontSize="15" FontWeight="Bold"/>
                                            <TextBlock x:Name="TxtScheduleStatus2" Text="대기 중" Foreground="#94A3B8" FontSize="13" HorizontalAlignment="Right"/>
                                        </Grid>
                                        <Grid>
                                            <Grid.ColumnDefinitions>
                                                <ColumnDefinition Width="140"/>
                                                <ColumnDefinition Width="*"/>
                                            </Grid.ColumnDefinitions>
                                            <StackPanel Grid.Column="0" Orientation="Horizontal" VerticalAlignment="Center">
                                                <TextBox x:Name="TxtSchedHour2" Text="23" Width="45" Height="36" FontSize="16" FontWeight="Bold" Foreground="#00F2FE" Background="#1C2130" BorderBrush="#334155" HorizontalContentAlignment="Center" VerticalContentAlignment="Center"/>
                                                <TextBlock Text=":" Foreground="#FFFFFF" FontSize="18" FontWeight="Bold" Margin="6,3"/>
                                                <TextBox x:Name="TxtSchedMin2" Text="00" Width="45" Height="36" FontSize="16" FontWeight="Bold" Foreground="#00F2FE" Background="#1C2130" BorderBrush="#334155" HorizontalContentAlignment="Center" VerticalContentAlignment="Center"/>
                                            </StackPanel>
                                            <ComboBox x:Name="CmbSchedAction2" Grid.Column="1" Height="36" Background="#F1F5F9" Foreground="#000000" FontSize="13" FontWeight="SemiBold" VerticalContentAlignment="Center">
                                                <ComboBoxItem Content="🌙 절전 모드 (Sleep)" Foreground="#000000"/>
                                                <ComboBoxItem Content="💤 최대 절전 모드 (Hibernate)" Foreground="#000000"/>
                                                <ComboBoxItem Content="🖥️ 화면만 끄기 (Screen Off)" Foreground="#000000"/>
                                                <ComboBoxItem Content="🔌 PC 완전 종료 (Shutdown)" Foreground="#000000" IsSelected="True"/>
                                                <ComboBoxItem Content="🔄 PC 다시 시작 (Restart)" Foreground="#000000"/>
                                            </ComboBox>
                                        </Grid>
                                    </StackPanel>
                                </Border>
                            </StackPanel>
                        </Grid>

                        <!-- PANEL 4: Power Plan -->
                        <Grid x:Name="PanelPowerPlan" Visibility="Collapsed">
                            <StackPanel>
                                <TextBlock Text="🔋 Windows 전원 플랜 관리" Foreground="#F8FAFC" FontSize="20" FontWeight="Bold"/>
                                <TextBlock Text="상황에 맞는 전원 옵션(절전 / 균형 / 고성능)을 빠르게 변경합니다." Foreground="#94A3B8" FontSize="13" Margin="0,4,0,20"/>

                                <ListBox x:Name="ListPowerPlans" Height="180" Background="#0F172A" Foreground="#FFFFFF" BorderBrush="#334155" Margin="0,0,0,20">
                                    <ListBox.ItemTemplate>
                                        <DataTemplate>
                                            <TextBlock Text="{Binding}" FontSize="14" Padding="8"/>
                                        </DataTemplate>
                                    </ListBox.ItemTemplate>
                                </ListBox>

                                <StackPanel Orientation="Horizontal" HorizontalAlignment="Center">
                                    <Button x:Name="BtnSetPowerSaver" Content="🍃 절전 모드 전환" Width="140" Margin="0,0,10,0"/>
                                    <Button x:Name="BtnSetBalanced" Content="⚖️ 균형 조정 전환" Width="140" Margin="0,0,10,0"/>
                                    <Button x:Name="BtnSetHighPerf" Content="🚀 고성능 전환" Width="140"/>
                                </StackPanel>
                            </StackPanel>
                        </Grid>
                    </Grid>
                </Border>
            </Grid>

            <!-- Bottom Status Bar -->
            <Border Grid.Row="2" Background="#1C2130" CornerRadius="0,0,16,16">
                <Grid Margin="20,0">
                    <TextBlock x:Name="TxtFooterStatus" Text="PC PowerSaver 준비됨" Foreground="#94A3B8" FontSize="13" VerticalAlignment="Center"/>
                    <TextBlock Text="Designed for Windows | Antigravity AI" Foreground="#475569" FontSize="11" HorizontalAlignment="Right" VerticalAlignment="Center"/>
                </Grid>
            </Border>
        </Grid>
    </Border>
</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [System.Windows.Markup.XamlReader]::Load($reader)

# Find Window Controls
$HeaderBar = $window.FindName("HeaderBar")
$BtnMinimize = $window.FindName("BtnMinimize")
$BtnClose = $window.FindName("BtnClose")

$NavTimer = $window.FindName("NavTimer")
$NavIdle = $window.FindName("NavIdle")
$NavSchedule = $window.FindName("NavSchedule")
$NavPowerPlan = $window.FindName("NavPowerPlan")

$PanelTimer = $window.FindName("PanelTimer")
$PanelIdle = $window.FindName("PanelIdle")
$PanelSchedule = $window.FindName("PanelSchedule")
$PanelPowerPlan = $window.FindName("PanelPowerPlan")

$BtnQuickScreenOff = $window.FindName("BtnQuickScreenOff")
$BtnQuickSleep = $window.FindName("BtnQuickSleep")
$BtnCaffeineToggle = $window.FindName("BtnCaffeineToggle")

$SliderTimerMinutes = $window.FindName("SliderTimerMinutes")
$TxtTimerMinutes = $window.FindName("TxtTimerMinutes")
$CmbTimerAction = $window.FindName("CmbTimerAction")
$TxtTimerStatus = $window.FindName("TxtTimerStatus")
$ProgressTimer = $window.FindName("ProgressTimer")
$BtnStartTimer = $window.FindName("BtnStartTimer")
$BtnCancelTimer = $window.FindName("BtnCancelTimer")

$BtnPreset15 = $window.FindName("BtnPreset15")
$BtnPreset30 = $window.FindName("BtnPreset30")
$BtnPreset60 = $window.FindName("BtnPreset60")
$BtnPreset120 = $window.FindName("BtnPreset120")

$ChkEnableIdle = $window.FindName("ChkEnableIdle")
$SliderIdleMinutes = $window.FindName("SliderIdleMinutes")
$TxtIdleMinutes = $window.FindName("TxtIdleMinutes")
$CmbIdleAction = $window.FindName("CmbIdleAction")
$TxtCurrentIdleTime = $window.FindName("TxtCurrentIdleTime")

$ChkEnableSchedule1 = $window.FindName("ChkEnableSchedule1")
$TxtSchedHour1 = $window.FindName("TxtSchedHour1")
$TxtSchedMin1 = $window.FindName("TxtSchedMin1")
$CmbSchedAction1 = $window.FindName("CmbSchedAction1")
$TxtScheduleStatus1 = $window.FindName("TxtScheduleStatus1")

$ChkEnableSchedule2 = $window.FindName("ChkEnableSchedule2")
$TxtSchedHour2 = $window.FindName("TxtSchedHour2")
$TxtSchedMin2 = $window.FindName("TxtSchedMin2")
$CmbSchedAction2 = $window.FindName("CmbSchedAction2")
$TxtScheduleStatus2 = $window.FindName("TxtScheduleStatus2")

$ListPowerPlans = $window.FindName("ListPowerPlans")
$BtnSetPowerSaver = $window.FindName("BtnSetPowerSaver")
$BtnSetBalanced = $window.FindName("BtnSetBalanced")
$BtnSetHighPerf = $window.FindName("BtnSetHighPerf")

$TxtFooterStatus = $window.FindName("TxtFooterStatus")

# State Variables
$script:TimerActive = $false
$script:TotalTimerSeconds = 0
$script:RemainingTimerSeconds = 0
$script:CaffeineActive = $false

# Window Dragging & Title Bar Actions
$HeaderBar.Add_MouseLeftButtonDown({
    $window.DragMove()
})

$BtnMinimize.Add_Click({
    $window.WindowState = [System.Windows.WindowState]::Minimized
})

$BtnClose.Add_Click({
    [Win32Power]::SetKeepAwake($false)
    $window.Close()
})

# Navigation Switching Helper
function Switch-Tab($activePanel, $activeNav) {
    $Panels = @($PanelTimer, $PanelIdle, $PanelSchedule, $PanelPowerPlan)
    $Navs = @($NavTimer, $NavIdle, $NavSchedule, $NavPowerPlan)

    foreach ($p in $Panels) { $p.Visibility = [System.Windows.Visibility]::Collapsed }
    foreach ($n in $Navs) {
        $n.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#2A2F3D")
        $n.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#E0E6ED")
    }

    $activePanel.Visibility = [System.Windows.Visibility]::Visible
    $activeNav.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#00F2FE")
    $activeNav.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#0F172A")
}

$NavTimer.Add_Click({ Switch-Tab $PanelTimer $NavTimer })
$NavIdle.Add_Click({ Switch-Tab $PanelIdle $NavIdle })
$NavSchedule.Add_Click({ Switch-Tab $PanelSchedule $NavSchedule })
$NavPowerPlan.Add_Click({ 
    Switch-Tab $PanelPowerPlan $NavPowerPlan 
    Update-PowerPlans
})

# Slider & Presets
$SliderTimerMinutes.Add_ValueChanged({
    $TxtTimerMinutes.Text = [int]$SliderTimerMinutes.Value
})

$BtnPreset15.Add_Click({ $SliderTimerMinutes.Value = 15 })
$BtnPreset30.Add_Click({ $SliderTimerMinutes.Value = 30 })
$BtnPreset60.Add_Click({ $SliderTimerMinutes.Value = 60 })
$BtnPreset120.Add_Click({ $SliderTimerMinutes.Value = 120 })

$SliderIdleMinutes.Add_ValueChanged({
    $TxtIdleMinutes.Text = "$([int]$SliderIdleMinutes.Value) 분"
})

# Action Execution Engine
function Execute-PowerAction($actionIndex) {
    switch ($actionIndex) {
        0 { 
            # Sleep
            $TxtFooterStatus.Text = "절전 모드로 전환합니다..."
            [System.Windows.Forms.Application]::SetSuspendState([System.Windows.Forms.PowerState]::Suspend, $false, $false)
        }
        1 { 
            # Hibernate
            $TxtFooterStatus.Text = "최대 절전 모드로 전환합니다..."
            [System.Windows.Forms.Application]::SetSuspendState([System.Windows.Forms.PowerState]::Hibernate, $false, $false)
        }
        2 { 
            # Screen Off
            $TxtFooterStatus.Text = "화면 전원을 끕니다."
            [Win32Power]::TurnOffDisplay()
        }
        3 { 
            # Shutdown
            $TxtFooterStatus.Text = "PC를 종료합니다."
            Stop-Computer -Force
        }
        4 { 
            # Restart
            $TxtFooterStatus.Text = "PC를 다시 시작합니다."
            Restart-Computer -Force
        }
    }
}

# Quick Actions
$BtnQuickScreenOff.Add_Click({
    [Win32Power]::TurnOffDisplay()
    $TxtFooterStatus.Text = "화면 끄기 실행됨"
})

$BtnQuickSleep.Add_Click({
    $TxtFooterStatus.Text = "절전 모드 즉시 실행..."
    Execute-PowerAction 0
})

$BtnCaffeineToggle.Add_Click({
    $script:CaffeineActive = -not $script:CaffeineActive
    if ($script:CaffeineActive) {
        [Win32Power]::SetKeepAwake($true)
        $BtnCaffeineToggle.Content = "☕ 카페인 모드: ON"
        $BtnCaffeineToggle.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#10B981")
        $TxtFooterStatus.Text = "카페인 모드 활성화 (절전 방지 중)"
    } else {
        [Win32Power]::SetKeepAwake($false)
        $BtnCaffeineToggle.Content = "☕ 카페인 모드: OFF"
        $BtnCaffeineToggle.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#334155")
        $TxtFooterStatus.Text = "카페인 모드 해제됨"
    }
})

# Main Timer Logic
$timer = New-Object System.Windows.Threading.DispatcherTimer
$timer.Interval = [TimeSpan]::FromSeconds(1)

$timer.Add_Tick({
    # 1. Countdown Timer
    if ($script:TimerActive) {
        $script:RemainingTimerSeconds--
        if ($script:RemainingTimerSeconds -le 0) {
            $script:TimerActive = $false
            $timer.Stop()
            $TxtTimerStatus.Text = "타이머 완료! 동작 실행 중..."
            $ProgressTimer.Value = 100
            $BtnStartTimer.IsEnabled = $true
            $BtnCancelTimer.IsEnabled = $false
            
            Execute-PowerAction $CmbTimerAction.SelectedIndex
        } else {
            $ts = [TimeSpan]::FromSeconds($script:RemainingTimerSeconds)
            $TxtTimerStatus.Text = "남은 시간: {0:D2}:{1:D2}:{2:D2}" -f $ts.Hours, $ts.Minutes, $ts.Seconds
            $elapsed = $script:TotalTimerSeconds - $script:RemainingTimerSeconds
            $ProgressTimer.Value = ($elapsed / $script:TotalTimerSeconds) * 100
        }
    }

    # 2. Idle Detection Logic
    $idleSec = [Win32Power]::GetIdleTimeSeconds()
    $idleMin = [math]::Floor($idleSec / 60)
    $remSec = $idleSec % 60
    $TxtCurrentIdleTime.Text = "현재 부재 시간: {0}분 {1}초" -f $idleMin, $remSec

    if ($ChkEnableIdle.IsChecked -and ($idleSec -ge ([int]$SliderIdleMinutes.Value * 60))) {
        # Trigger Idle Action once threshold crossed
        $TxtFooterStatus.Text = "부재 임계 시간 도달. 절전 실행..."
        Execute-PowerAction $CmbIdleAction.SelectedIndex
    }

    # 3. Schedule 1 Check Logic
    if ($ChkEnableSchedule1.IsChecked) {
        $now = Get-Date
        $targetH1 = [int]$TxtSchedHour1.Text
        $targetM1 = [int]$TxtSchedMin1.Text
        $TxtScheduleStatus1.Text = "예약 1: {0:D2}:{1:D2} 대기 중" -f $targetH1, $targetM1
        if ($now.Hour -eq $targetH1 -and $now.Minute -eq $targetM1 -and $now.Second -le 1) {
            $TxtFooterStatus.Text = "예약 1 시각 도달. 지정 동작 실행..."
            Execute-PowerAction $CmbSchedAction1.SelectedIndex
        }
    } else {
        $TxtScheduleStatus1.Text = "예약 1: 비활성화됨"
    }

    # 4. Schedule 2 Check Logic
    if ($ChkEnableSchedule2.IsChecked) {
        $now = Get-Date
        $targetH2 = [int]$TxtSchedHour2.Text
        $targetM2 = [int]$TxtSchedMin2.Text
        $TxtScheduleStatus2.Text = "예약 2: {0:D2}:{1:D2} 대기 중" -f $targetH2, $targetM2
        if ($now.Hour -eq $targetH2 -and $now.Minute -eq $targetM2 -and $now.Second -le 1) {
            $TxtFooterStatus.Text = "예약 2 시각 도달. 지정 동작 실행..."
            Execute-PowerAction $CmbSchedAction2.SelectedIndex
        }
    } else {
        $TxtScheduleStatus2.Text = "예약 2: 비활성화됨"
    }
})

$BtnStartTimer.Add_Click({
    $mins = [int]$TxtTimerMinutes.Text
    if ($mins -le 0) { return }

    $script:TotalTimerSeconds = $mins * 60
    $script:RemainingTimerSeconds = $script:TotalTimerSeconds
    $script:TimerActive = $true

    $BtnStartTimer.IsEnabled = $false
    $BtnCancelTimer.IsEnabled = $true
    $TxtFooterStatus.Text = "카운트다운 타이머가 시작되었습니다."

    if (-not $timer.IsEnabled) { $timer.Start() }
})

$BtnCancelTimer.Add_Click({
    $script:TimerActive = $false
    $TxtTimerStatus.Text = "남은 시간: 대기 중"
    $ProgressTimer.Value = 0
    $BtnStartTimer.IsEnabled = $true
    $BtnCancelTimer.IsEnabled = $false
    $TxtFooterStatus.Text = "타이머가 취소되었습니다."
})

# Power Plan Switching Logic
function Update-PowerPlans {
    $ListPowerPlans.Items.Clear()
    $plans = powercfg /list
    foreach ($line in $plans) {
        if ($line -match 'GUID:\s+([a-f0-9\-]+)\s+\(([^)]+)\)(\s+\*)?') {
            $guid = $Matches[1]
            $name = $Matches[2]
            $active = if ($Matches[3]) { " [현재 사용 중]" } else { "" }
            $ListPowerPlans.Items.Add("$name ($guid)$active")
        }
    }
}

$BtnSetPowerSaver.Add_Click({
    powercfg /setactive a1841308-3541-4fab-bc81-f71556f20b4a # Power Saver GUID
    Update-PowerPlans
    $TxtFooterStatus.Text = "전원 모드: [절전 모드]로 전환됨"
})

$BtnSetBalanced.Add_Click({
    powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e # Balanced GUID
    Update-PowerPlans
    $TxtFooterStatus.Text = "전원 모드: [균형 조정]으로 전환됨"
})

$BtnSetHighPerf.Add_Click({
    powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c # High Performance GUID
    Update-PowerPlans
    $TxtFooterStatus.Text = "전원 모드: [고성능]으로 전환됨"
})

# Start Master Timer for Idle/Schedule ticks
$timer.Start()

# Show GUI Window
$window.ShowDialog() | Out-Null
