#include <winrt/Windows.Foundation.h>
#include <winrt/Windows.Media.h>
#include <winrt/Windows.Media.MediaProperties.h>

using namespace winrt;
using namespace Windows::Media;

// Exported function for Flutter platform channel call
extern "C" __declspec(dllexport) void UpdateSMTCDisplay()
{
    // Initialize the Windows Runtime (if not already initialized)
    init_apartment(apartment_type::single_threaded);

    // Get the System Media Transport Controls for the current view
    auto smtc = SystemMediaTransportControls::GetForCurrentView();

    // Optionally enable the play/pause buttons
    smtc.IsPlayEnabled(true);
    smtc.IsPauseEnabled(true);

    // Update the display metadata
    auto updater = smtc.DisplayUpdater();
    updater.Type(MediaPlaybackType::Music);
    updater.MusicProperties().Title(L"Your Song Title");
    updater.MusicProperties().Artist(L"Your Artist Name");
    // (You can set additional metadata or a thumbnail here if desired)
    updater.Update();

    // Set the playback status to indicate that media is playing
    smtc.PlaybackStatus(MediaPlaybackStatus::Playing);
}
