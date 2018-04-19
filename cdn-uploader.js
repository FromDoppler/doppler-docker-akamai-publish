const ftp = require("basic-ftp");

const config = {
	host: process.env.AKAMAI_CDN_HOSTNAME,
	user: process.env.AKAMAI_CDN_USERNAME,
	password: process.env.AKAMAI_CDN_PASSWORD,
	cpCode: process.env.AKAMAI_CDN_CPCODE,
	port: 21
}

function UploadFilesFromPath(config) {
	console.log("[+] Connecting to CDN...");
	async function Upload() {
		try {
			const client = new ftp.Client();
			await client.connect(config.host, config.port);
			await client.login(config.user, config.password);
			await client.useDefaultSettings();
			console.log(`[+] Starting to upload the content of "${config.sourcePath}".`);
			await client.ensureDir(`/${config.cpCode}/${config.projectName}`);
			await client.uploadDir(config.sourcePath, config.versionName);
			console.log(`[+] Folder "${config.sourcePath}" uploaded.`);
			client.close();
		}
		catch(err) {
			console.log(err);
			throw "[-] Upload error. The process will be terminated."
		}
	}
	Upload();
}

function UpdateConfigWithArgs(argv, config){
	var args = [].slice.call(argv);
	args.splice(0, 2);
	config.sourcePath = args[0];
	config.projectName = args[1];
	config.versionName = args[2];
	
	
}
process.on('unhandledRejection', up => { throw up })
UpdateConfigWithArgs(process.argv, config);
UploadFilesFromPath(config);