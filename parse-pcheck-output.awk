BEGIN { ret = 0; }

/NonsolvableDeps|IUSEMetadataReport|LicenseMetadataReport|VisibilityReport/ {
	ret = 1;
	printf("%s", "\033[42m[FATAL] ");
	print;
	printf("%s", "\033[49m");
	next;
}

/Killed/ {
	ret = 2;
	printf("%s", "\033[43;30m");
	print;
	printf("%s", "\033[49;39m");
	next;
}

{
	print;
}

END { exit ret; }
