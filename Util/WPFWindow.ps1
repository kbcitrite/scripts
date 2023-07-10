function Load-Controls
{
    param (
        $window,
        $ManualControls)
    foreach ($GridRow in $window.Content.Children.name)
    {
        foreach ($Object in $window.Content.Children | Where-Object { $_.Name -eq $GridRow })
        {
            foreach ($ChildObject in $Object.Children)
            {
                if ($ChildObject.Name)
                {
                    Set-Variable -Name $ChildObject.Name -Value $ChildObject -Scope Script 
                    foreach ($GrandChildObject in $ChildObject.Children)
                    {
                        if ($GrandChildObject.Name)
                        {
                            Set-Variable -Name $GrandChildObject.Name -Value $GrandChildObject -Scope Script 
                            foreach ($GreatGrandChildObject in $GrandChildObject.Children)
                            {
                                if ($GreatGrandChildObject.Name)
                                {
                                    Set-Variable -Name $GreatGrandChildObject.Name -Value $GreatGrandChildObject -Scope Script
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    foreach ($ManualControl in $ManualControls)
    {
        Set-Variable -Name $ManualControl -Value $window.FindName($ManualControl) -Scope Script
    }
}
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms
$showWindowAsync = Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class Win32ShowWindowAsync
{
    [DllImport("user32.dll")]
    public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
}
"@ -PassThru

[void]$showWindowAsync::ShowWindowAsync((Get-Process -Id $pid).MainWindowHandle, 2)
$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
Title="Windows Packet Capture" Height="450" Width="800" MinWidth="700" MinHeight="200">
<Window.Resources>
<CollectionViewSource x:Key="outputDataViewSource" Source="{Binding}" />
</Window.Resources>
<Grid>
<Grid.RowDefinitions>
    <RowDefinition Height="Auto" />
    <RowDefinition Height="Auto" />
    <RowDefinition Height="*" />
</Grid.RowDefinitions>
<StackPanel Orientation="Horizontal" Margin="1">
    <Button Name="StartButton" Content="Start" Width="50" Margin="1"/>
    <Button Name="StopButton" Content="Stop" Width="50" Margin="1" IsEnabled="False"/>
    <CheckBox Name="RealTimeCheckbox" Content="Real-Time" Margin="10 0 0 0" VerticalAlignment="Center"/>
    <Label Name="MaxEventsLabel" Content="Max Events:" VerticalAlignment="Center" IsEnabled="False"/>            
    <TextBox Name="MaxEvents" Width="56" Margin="1" VerticalContentAlignment="Center" Text="10000" IsEnabled="False" />
    <CheckBox Name="AutoScrollCheckBox" Content="Auto Scroll" Margin="10 0 0 0" VerticalAlignment="Center" IsChecked="{Binding IsAutoScrollEnabled}" />
    <CheckBox Name="SaveOutput" Content="Save to .pcapng" Margin="10 0 0 0" VerticalAlignment="Center" IsChecked="True" />
</StackPanel>
<StackPanel Orientation="Horizontal" Margin="1" Grid.Row="1">
    <Label Content="Ports:" VerticalAlignment="Center" />
    <TextBox Name="PortTextBox" Width="30" Margin="1" VerticalContentAlignment="Center" />
    <Button Name="AddPortButton" Content="Add" Margin="1" Width="45" />
    <Button Name="RemovePortButton" Content="Remove" Margin="1" Width="55" />
    <ListBox Name="FilterPorts" Width="60" Margin="1" MaxHeight="200" Height="25" />
    <Label Content="IPs:" VerticalAlignment="Center" />
    <TextBox Name="IPTextBox" Width="100" Margin="1" VerticalContentAlignment="Center" />
    <Button Name="AddIpButton" Content="Add" Margin="1" Width="45" />
    <Button Name="RemoveIpButton" Content="Remove" Margin="1" Width="55" />
    <ListBox Name="FilterIPs" Width="158" Margin="1" MaxHeight="200" Height="25" />
</StackPanel>
<ScrollViewer x:Name="ScrollViewer" Grid.Row="2" CanContentScroll="True" IsEnabled="False" >
    <DataGrid x:Name="OutputDataGrid" IsReadOnly="True" AutoGenerateColumns="False" ItemsSource="{Binding}" HorizontalAlignment="Stretch" VerticalAlignment="Stretch" CanUserAddRows="False" EnableColumnVirtualization="True" EnableRowVirtualization="True" VirtualizingStackPanel.IsVirtualizing="True" VirtualizingStackPanel.VirtualizationMode="Standard" IsEnabled="False">
        <DataGrid.Columns>
            <DataGridTextColumn Header="Timestamp" Binding="{Binding Timestamp, StringFormat={}{0:yyyy-MM-dd HH:mm:ss.fff}}" Width="Auto" />
            <DataGridTextColumn Header="Source IP" Binding="{Binding SourceIP}" Width="Auto" />
            <DataGridTextColumn Header="Source Port" Binding="{Binding SourcePort}" Width="Auto" />
            <DataGridTextColumn Header="Dest. IP" Binding="{Binding DestIP}" Width="Auto" />
            <DataGridTextColumn Header="Dest. Port" Binding="{Binding DestPort}" Width="Auto" /> 
            <DataGridTextColumn Header="Info" Binding="{Binding Info}" Width="Auto" />
        </DataGrid.Columns>
    </DataGrid>
</ScrollViewer>
</Grid>
</Window>
"@
$theme = @"
<ResourceDictionary xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
                    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml">

    <SolidColorBrush x:Key="BackgroundColor" Color="#333333"/>
    <SolidColorBrush x:Key="ForegroundColor" Color="#FFFFFF"/>
    <SolidColorBrush x:Key="SecondaryForegroundColor" Color="#999999"/>

    <Style TargetType="{x:Type TextBlock}">
        <Setter Property="Foreground" Value="{StaticResource ForegroundColor}"/>
        <Setter Property="Background" Value="{StaticResource BackgroundColor}"/>
    </Style>

    <Style TargetType="{x:Type Button}">
        <Setter Property="Foreground" Value="{StaticResource ForegroundColor}"/>
        <Setter Property="Background" Value="{StaticResource BackgroundColor}"/>
        <Setter Property="BorderBrush" Value="{StaticResource ForegroundColor}"/>
    </Style>

    <Style TargetType="{x:Type ListBox}">
        <Setter Property="Foreground" Value="{StaticResource ForegroundColor}"/>
        <Setter Property="Background" Value="{StaticResource BackgroundColor}"/>
        <Setter Property="BorderBrush" Value="{StaticResource ForegroundColor}"/>
    </Style>
    <Style TargetType="{x:Type DataGrid}">
        <Setter Property="Foreground" Value="{StaticResource ForegroundColor}"/>
        <Setter Property="Background" Value="{StaticResource BackgroundColor}"/>
        <Setter Property="BorderBrush" Value="{StaticResource ForegroundColor}"/>
    </Style>
    <Style TargetType="{x:Type DataGridColumnHeader}">
        <Setter Property="Foreground" Value="{StaticResource ForegroundColor}"/>
        <Setter Property="Background" Value="{StaticResource BackgroundColor}"/>
    </Style>
    <Style TargetType="{x:Type Grid}">        
        <Setter Property="Background" Value="{StaticResource BackgroundColor}"/>
    </Style>
    <Style TargetType="{x:Type DataGridRow}">
        <Setter Property="Background" Value="{StaticResource BackgroundColor}"/>
        <Setter Property="BorderBrush" Value="{StaticResource ForegroundColor}"/>
        <Setter Property="BorderThickness" Value="0,0,0,1"/>
        <Style.Triggers>
            <Trigger Property="IsSelected" Value="True">
                <Setter Property="Background" Value="#1E90FF"/>
                <Setter Property="Foreground" Value="{StaticResource ForegroundColor}"/>
            </Trigger>
        </Style.Triggers>
    </Style>
    <Style TargetType="{x:Type TextBox}">
        <Setter Property="Foreground" Value="{StaticResource ForegroundColor}"/>
        <Setter Property="Background" Value="{StaticResource BackgroundColor}"/>
        <Setter Property="BorderBrush" Value="{StaticResource ForegroundColor}"/>
        <Style.Triggers>
            <Trigger Property="IsEnabled" Value="False">
                <Setter Property="Foreground" Value="{StaticResource SecondaryForegroundColor}"/>
            </Trigger>
        </Style.Triggers>
    </Style>
    <Style TargetType="{x:Type StackPanel}">
        <Setter Property="Background" Value="{StaticResource BackgroundColor}" />
        <Style.Resources>
            <Style TargetType="{x:Type TextBlock}">
                <Setter Property="Foreground" Value="{StaticResource ForegroundColor}" />
            </Style>
        </Style.Resources>
    </Style>
    <Style TargetType="{x:Type Label}">
        <Setter Property="Foreground" Value="{StaticResource ForegroundColor}" />
        <Setter Property="Background" Value="{StaticResource BackgroundColor}" />
    </Style>
    <Style TargetType="{x:Type CheckBox}">
        <Setter Property="Foreground" Value="White" />
    </Style>
</ResourceDictionary>
"@
$reader = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new($xaml))
$window = [Windows.Markup.XamlReader]::Load($reader)
$script:UserTheme = (Get-Item -Path 'hkcu:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' | Get-ItemProperty).AppsUseLightTheme
if ($script:UserTheme -eq 0)
{
    $themereader = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new($theme))
    $themexaml = [Windows.Markup.XamlReader]::Load($themereader)
    $window.Resources.MergedDictionaries.Add($themexaml)
    $script:darkHyperlinkColor = [System.Windows.Media.ColorConverter]::ConvertFromString("#03d3fc")
}
#$window.Icon = [System.Convert]::FromBase64String("")
Load-Controls -window $window
$window.Title = "Packet Capture"
$window.ShowDialog()
$window.BringIntoView()
