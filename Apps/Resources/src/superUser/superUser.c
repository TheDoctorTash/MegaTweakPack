/* Windows Vista, the earliest to utilize the Trusted Installer */
#define _WIN32_WINNT _WIN32_WINNT_VISTA

#include <Windows.h>

#include <stdio.h>

#include "tokens.h" /* Defines lplpwcszTokenPrivileges */

/*
	Return codes -
		1 - Invalid argument
		2 - Failed acquiring SeDebugPrivilege
		4 - Could not start/open the TrustedInstaller service
		5 - Process creation failed
 */

/* Fix for the MSVCRT */
__declspec(dllimport) FILE* __cdecl __iob_func();

FILE* __cdecl __acrt_iob_func(unsigned Index)
{
	return (FILE*)((char*)__iob_func() + Index * (sizeof(char*) * 3 + sizeof(int) * 5));
}

#define wputs _putws
#define MAX_COMMANDLINE 8192 /* Presumably the maximum commandline length */
#define wprintfv(...) \
if(params.bVerbose) \
	wprintf(__VA_ARGS__); /* Only use when bVerbose in scope */

static inline void acquireSeDebugPrivilege(void);
static inline int createTrustedInstallerProcess(wchar_t* lpwszImageName);
static inline HANDLE getTrustedInstallerPHandle(void);
static inline void setAllPrivileges(HANDLE hProcessToken);
static inline int enableTokenPrivilege(HANDLE hToken, const wchar_t* lpwcszPrivilege);
void printHelp(void);

struct parameters {
	unsigned int bVerbose : 1;			/* Whether to print debug messages or not.*/
	unsigned int bWait : 1;				/* Whether to wait to finish created process */
	unsigned int bCommandPresent : 1;	/* Whether there is a user-specified command ("/c" argument) */
};

struct parameters params = { 0 };
unsigned int cParams = 0;

int wmain(int argc, wchar_t *argv[]) {

	wchar_t* lpwszImageName; /* Name of the process to create - basically what's after "/c" or "cmd.exe" */

	/* Parse commandline options */

	for (int i = 1; i < argc; ++i)
		if ((*argv[i] == '/' || *argv[i] == '-') && *(argv[i] + 1) != '\0') {
			/* Check for an at-least-two-character string beginning with '/' or '-' */
			cParams++;

			switch (*(argv[i] + 1)) {
			case 'h':
				printHelp();
				return 0;
				
				break;
			case 'v':
				params.bVerbose = 1;
				
				break;
			case 'w':
				params.bWait = 1;
				
				break;
			case 'c':
				params.bCommandPresent = 1;
				goto done_params;

				break;
			default:
				/* Shouldn't happen before "/c", will need to throw an error unless we simply ignore invalid arguments */
				fwprintf(stderr, L"[E] Invalid argument\n");
				exit(1);
				break;
			}
		}
done_params:

	if (params.bCommandPresent) {
		/* Get commandline arguments */
		wchar_t* lpwszCommandLine = GetCommandLine();
		size_t cCharSkip = 1;

		if (*lpwszCommandLine == '\"') /* Skip surrounding quotation marks, if present */
			cCharSkip += 2;
		
		for (unsigned int i = 0; i < cParams + 1; ++i)
			cCharSkip += wcslen(argv[i]) + 1;
		
		lpwszImageName = calloc(wcslen(lpwszCommandLine + cCharSkip), sizeof(wchar_t));
		wcscpy_s(lpwszImageName, wcslen(lpwszCommandLine + cCharSkip) + 1, lpwszCommandLine + cCharSkip);

	}
	else {
		lpwszImageName = calloc(7, sizeof(wchar_t));
		wcscpy_s(lpwszImageName, 8, L"cmd.exe");
	}

	wprintfv(L"[D] Your commandline is \"%s\"\n", lpwszImageName);

	createTrustedInstallerProcess(lpwszImageName);

	return 0;
}

static inline int createTrustedInstallerProcess(wchar_t* lpwszImageName) {
	
	STARTUPINFOEX startupInfo = { 0 };

	acquireSeDebugPrivilege();

	/* Start the TrustedInstaller service */
	HANDLE hTIPHandle = getTrustedInstallerPHandle();
	if (hTIPHandle == NULL) {
		fwprintf(stderr, L"[E] Could not open/start the TrustedInstaller service\n");
		exit(3);
	}

	/* Initialize STARTUPINFO */

	startupInfo.StartupInfo.cb = sizeof(STARTUPINFOEX);

	startupInfo.StartupInfo.dwFlags = STARTF_USESHOWWINDOW;
	startupInfo.StartupInfo.wShowWindow = SW_SHOWNORMAL;

	/* Initialize attribute lists for "parent assignment" */
	
	size_t attributeListLength;

	InitializeProcThreadAttributeList(NULL, 1, 0, (size_t*)&attributeListLength);

	startupInfo.lpAttributeList = HeapAlloc(GetProcessHeap(), HEAP_ZERO_MEMORY, attributeListLength);
	InitializeProcThreadAttributeList(startupInfo.lpAttributeList, 1, 0, (size_t*)&attributeListLength);

	UpdateProcThreadAttribute(startupInfo.lpAttributeList, 0, PROC_THREAD_ATTRIBUTE_PARENT_PROCESS, &hTIPHandle, sizeof(HANDLE), NULL, NULL);

	/* Create process */
	PROCESS_INFORMATION processInfo = { 0 };
	wprintfv(L"[D] Creating specified process\n");

	if (CreateProcess(
		NULL,
		lpwszImageName,
		NULL,
		NULL,
		FALSE,
		CREATE_SUSPENDED | EXTENDED_STARTUPINFO_PRESENT | CREATE_NEW_CONSOLE,
		NULL,
		NULL,
		&startupInfo.StartupInfo,
		&processInfo
	)) {
		DeleteProcThreadAttributeList(startupInfo.lpAttributeList);
		HeapFree(GetProcessHeap(), 0, startupInfo.lpAttributeList);

		HANDLE hProcessToken;
		OpenProcessToken(processInfo.hProcess, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, &hProcessToken);
		setAllPrivileges(hProcessToken);

		wprintfv(L"[D] Created process ID: %ld and assigned additional token privileges.\n [D] Resuming..\n", processInfo.dwProcessId);

		ResumeThread(processInfo.hThread);

		if (params.bWait) {
			/* TODO Add somehow returning the child's exit code */
			wprintfv(L"[D] Waiting for process to exit\n");
			WaitForSingleObject(processInfo.hProcess, INFINITE);
			wprintfv(L"[D] Process exited\n");
		}

		CloseHandle(processInfo.hThread);
		CloseHandle(processInfo.hProcess);
		
		return 1;
	}
	else {
		/* Most commonly - 0x2 - The system cannot find the file specified. */
		fwprintf(stderr, L"[E] Process creation failed. Error code: 0x%08X\n", GetLastError());
		exit(4);
	}

}

static inline void setAllPrivileges(HANDLE hProcessToken) {
	/* Iterate over lplpwcszTokenPrivileges to add all privileges to a token */
	for (int i = 0; i < (sizeof(lplpcwszTokenPrivileges) / sizeof(*lplpcwszTokenPrivileges)); ++i)
		if (!enableTokenPrivilege(hProcessToken, lplpcwszTokenPrivileges[i]))
			wprintfv(L"[D] Could not set privilege [%s], you most likely don't have it.\n", lplpcwszTokenPrivileges[i]);
}

static inline HANDLE getTrustedInstallerPHandle(void) {
	HANDLE hSCManager, hTIService;
	SERVICE_STATUS_PROCESS lpServiceStatusBuffer = { 0 };

	hSCManager = OpenSCManager(NULL, NULL, SC_MANAGER_CREATE_SERVICE | SC_MANAGER_CONNECT);
	hTIService = OpenService(hSCManager, L"TrustedInstaller", SERVICE_START | SERVICE_QUERY_STATUS);

	if (hTIService == NULL)
		goto cleanup_and_fail;
	
	do {
		unsigned long ulBytesNeeded;
		QueryServiceStatusEx(hTIService, SC_STATUS_PROCESS_INFO, (unsigned char*)&lpServiceStatusBuffer, sizeof(SERVICE_STATUS_PROCESS), &ulBytesNeeded);
		
		if (lpServiceStatusBuffer.dwCurrentState == SERVICE_STOPPED)
			if (!StartService(hTIService, 0, NULL))
				goto cleanup_and_fail;

	} while (lpServiceStatusBuffer.dwCurrentState == SERVICE_STOPPED);

	CloseServiceHandle(hSCManager);
	CloseServiceHandle(hTIService);

	return OpenProcess(PROCESS_CREATE_PROCESS, FALSE, lpServiceStatusBuffer.dwProcessId);

cleanup_and_fail:
	CloseServiceHandle(hSCManager);
	CloseServiceHandle(hTIService);

	return NULL;
}

static inline void acquireSeDebugPrivilege(void) {
	HANDLE hThreadToken;
	int retry = 1;

reacquire_token:
	OpenThreadToken(GetCurrentThread(), TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, FALSE, &hThreadToken);
	if (GetLastError() == ERROR_NO_TOKEN && retry) {
		ImpersonateSelf(SecurityImpersonation);
		retry--;

		goto reacquire_token;
	}

	if (!enableTokenPrivilege(hThreadToken, SE_DEBUG_NAME)) {
		fwprintf(stderr, L"Acquiring SeDebugPrivilege failed!");
		exit(2);
	}
}

static inline int enableTokenPrivilege(
	HANDLE hToken,
	const wchar_t *lpwcszPrivilege
) {
	TOKEN_PRIVILEGES tp;
	LUID luid;
	TOKEN_PRIVILEGES prevTp;
	DWORD cbPrevious = sizeof(TOKEN_PRIVILEGES);

	if (!LookupPrivilegeValue(NULL, lpwcszPrivilege, &luid))
		return 0; /* Cannot lookup privilege value */

	tp.PrivilegeCount = 1;
	tp.Privileges[0].Luid = luid;
	tp.Privileges[0].Attributes = 0;

	AdjustTokenPrivileges(hToken, FALSE, &tp, sizeof(TOKEN_PRIVILEGES), &prevTp, &cbPrevious);

	if (GetLastError() != ERROR_SUCCESS)
		return 0;

	prevTp.PrivilegeCount = 1;
	prevTp.Privileges[0].Luid = luid;

	prevTp.Privileges[0].Attributes |= SE_PRIVILEGE_ENABLED;

	AdjustTokenPrivileges(hToken, FALSE, &prevTp, cbPrevious, NULL, NULL);
	
	if (GetLastError() != ERROR_SUCCESS)
		return 0;
	
	return 1;
}

static inline void printHelp(void) {
	wputs(
		L"superUser.exe [options] /c [Process Name]\n\
Options: (You can use either '-' or '/')\n\
\t/v - Display verbose messages.\n\
\t/w - Wait for the created process to finish before exiting.\n\
\t/h - Display this help message.\n\
\t/c - Specify command to execute. If not specified, a cmd instance is spawned.\n");
}