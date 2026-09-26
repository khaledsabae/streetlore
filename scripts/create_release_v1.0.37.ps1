$ErrorActionPreference = 'Stop'

Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public class CredMan {
    [StructLayout(LayoutKind.Sequential, CharSet=CharSet.Unicode)]
    public struct CREDENTIAL {
        public UInt32 Flags; public UInt32 Type;
        public IntPtr TargetName; public IntPtr Comment;
        public System.Runtime.InteropServices.ComTypes.FILETIME LastWritten;
        public UInt32 CredentialBlobSize; public IntPtr CredentialBlob;
        public UInt32 Persist; public UInt32 AttributeCount;
        public IntPtr Attributes; public IntPtr TargetAlias; public IntPtr UserName;
    }
    [DllImport("advapi32.dll", EntryPoint="CredReadW", CharSet=CharSet.Unicode, SetLastError=true)]
    public static extern bool CredRead(string target, UInt32 type, UInt32 reservedFlag, out IntPtr credentialPtr);
    [DllImport("advapi32.dll", EntryPoint="CredFree", SetLastError=true)]
    public static extern void CredFree(IntPtr buffer);
}
'@

$credPtr = [IntPtr]::Zero
[CredMan]::CredRead("git:https://github.com", 1, 0, [ref]$credPtr) | Out-Null
$cred = [System.Runtime.InteropServices.Marshal]::PtrToStructure($credPtr, [type][CredMan+CREDENTIAL])
$passwordBytes = New-Object byte[] $cred.CredentialBlobSize
[System.Runtime.InteropServices.Marshal]::Copy($cred.CredentialBlob, $passwordBytes, 0, $cred.CredentialBlobSize)
$TOKEN = [System.Text.Encoding]::Unicode.GetString($passwordBytes)
[CredMan]::CredFree($credPtr)

Write-Host "Token retrieved: $($TOKEN.Length) chars"

$headers = @{
    "Authorization" = "Bearer $TOKEN"
    "Accept" = "application/vnd.github+json"
    "X-GitHub-Api-Version" = "2022-11-28"
    "User-Agent" = "streetlore-release-script"
}

$tag = "v1.0.37"
$apkName = "streetlore-v1.0.37-arm64.apk"

$lines = @(
    '## What is new in v1.0.37 - Gemini model fallback chain + Check-in state persistence',
    '',
    '### 1. Gemini model fallback chain',
    '- `GeminiRestClient._modelFallbackOrder = [' + '''gemini-1.5-flash-002, gemini-1.5-flash-001, gemini-1.5-flash, gemini-1.0-pro''' + ']` - tried in order for EVERY key in the rotation.',
    '- On a `404 NOT_FOUND` for the current model name, the wrapper SILENTLY moves to the next model with the SAME key (same API key, different model identifier). This way one rolled-off model does not waste the rest of the key.',
    '- AppConfig.geminiModel promoted to `gemini-1.5-flash-002` so the call order is `002 -> 001 -> flash -> 1.0-pro`, then on a key failure rotate to the next key with the same model list reset.',
    '- The call site is unchanged - callers pass `model: AppConfig.geminiModel` and GeminiRestClient transparently prepends the requested model to the fallback chain (deduped).',
    '- Per-(key, model) attempt logged: `[GeminiRestClient] SDK call: model=gemini-1.5-flash-001 key=ABCD...wxyz keyAttempt=1/5 modelAttempt=2/4` so a bad model is immediately visible in logcat.',
    '',
    '### 2. Check-in state persists + duplicate-safe upsert',
    '- `place_details_screen.dart` now hydrates `_isVisited` in `initState` via a new `_loadCheckinState()` helper: it queries `place_checkins` for `(user_id, place_id)` and sets the green-check badge to `true` when the row exists. The user sees the "Visited" state the moment they re-enter a place they already checked in at - no more accidental duplicate taps.',
    '- The check-in tap calls the direct upsert with `onConflict: ''user_id, place_id''` so a re-tap becomes a graceful UPDATE rather than a duplicate INSERT. Net effect: re-tapping no longer surfaces `[23505] duplicate key value violates unique constraint` in a red SnackBar.',
    '- **REQUIRES SQL**: ensure `place_checkins` has a unique constraint on `(user_id, place_id)`. Run this once in Supabase SQL editor if you haven''t:',
    '  ```sql',
    '  alter table public.place_checkins',
    '    add constraint place_checkins_user_place_unique unique (user_id, place_id);',
    '  ```',
    '- The `_loadCheckinState()` failure path is non-fatal: missing connectivity falls back to the local "not visited" state until the next refresh, no exception bubbles up.',
    '- Working `place_checkins` schema reminder:',
    '  ```sql',
    '  create table if not exists public.place_checkins (',
    '    id bigint generated always as identity primary key,',
    '    user_id text not null,',
    '    place_id text not null,',
    '    checked_in_at timestamptz not null default now()',
    '  );',
    '  alter table public.place_checkins',
    '    add constraint place_checkins_user_place_unique unique (user_id, place_id);',
    '  alter table public.place_checkins enable row level security;',
    '  create policy "place_checkins_read"   on public.place_checkins for select   using (auth.uid()::text = user_id);',
    '  create policy "place_checkins_insert" on public.place_checkins for insert  with check (auth.uid()::text = user_id);',
    '  create policy "place_checkins_update" on public.place_checkins for update  using (auth.uid()::text = user_id);',
    '  ```',
    '',
    '### Working mechanics preserved (per handover rules)',
    '- Authentication: Google OAuth + Supabase (v1.0.30 Web Client ID + same keystore), unchanged.',
    '- Hotels markers: `onTap` wired to `_SelectedPlaceCard` (v1.0.33), unchanged.',
    '- Optimistic local counter bump on check-in success (v1.0.34), unchanged.',
    '- R8 / ProGuard still disabled (`isMinifyEnabled = false`).',
    '',
    '## Build',
    '- Target: arm64 only.',
    '- Release-signed with `android/app/release_v2.keystore` (alias `streetlore`, SHA-1 `AF:62:89:44:B5:F3:A0:0A:4E:CE:1E:72:34:13:26:EA:5A:E7:B4:8F`).',
    '- `flutter analyze`: 0 issues.',
    '- `--dart-define=GEMINI_API_KEYS=<5 keys>` (kept out of source).',
    '- Tag force-pushed (`git push origin v1.0.37 --force`).'
)
$releaseBody = $lines -join "`n"

$payload = @{
    tag_name = $tag
    name = 'v1.0.37 - Gemini model fallback chain + Check-in state persists'
    body = $releaseBody
    draft = $false
    prerelease = $false
} | ConvertTo-Json -Depth 10 -Compress

Write-Host "Checking existing release $tag..."
try {
    $release = Invoke-RestMethod -Uri "https://api.github.com/repos/mohamedsabae50-prog/streetlore/releases/tags/$tag" -Headers $headers
    Write-Host "Found existing release id=$($release.id) url=$($release.html_url)"
} catch {
    Write-Host "Creating new release..."
    $payloadPath = Join-Path $env:TEMP 'streetlore_release_payload.json'
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($payloadPath, $payload, $utf8)
    $release = Invoke-RestMethod -Uri "https://api.github.com/repos/mohamedsabae50-prog/streetlore/releases" -Method Post -Headers $headers -InFile $payloadPath -ContentType "application/json; charset=utf-8"
    Write-Host "Created release id=$($release.id) url=$($release.html_url)"
}

$uploadUrl = $release.upload_url -replace '\{.*$',''
Write-Host "Upload URL: $uploadUrl"

$apkPath = "D:\codes\streetlore\build\app\outputs\flutter-apk\$apkName"
if (-not (Test-Path $apkPath)) {
    throw "APK not found at $apkPath"
}
Write-Host "Uploading $apkPath..."

$uploadHeaders = @{
    "Authorization" = "Bearer $TOKEN"
    "Accept" = "application/vnd.github+json"
    "X-GitHub-Api-Version" = "2022-11-28"
    "User-Agent" = "streetlore-release-script"
    "Content-Type" = "application/vnd.android.package-archive"
}

$uploadUrlWithName = $uploadUrl + "?name=$apkName"
Write-Host "Final upload URL: $uploadUrlWithName"
Invoke-RestMethod -Uri $uploadUrlWithName -Method Post -Headers $uploadHeaders -InFile $apkPath -ContentType "application/vnd.android.package-archive"
Write-Host "Upload complete!"
Write-Host "Final URL: $($release.html_url)"
