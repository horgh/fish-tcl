/*
	Interface to fish blowfish implementation
*/

#include <tcl.h>
#include "blowfish.h"

static int
Encrypt_Cmd(ClientData cdata, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
	if (objc != 3) {
		Tcl_Obj *str = Tcl_ObjPrintf("wrong # args: should be \"encrypt key string\"");
		Tcl_SetObjResult(interp, str);
		return TCL_ERROR;
	}

	const char *key = Tcl_GetString(objv[1]);
	const char *s = Tcl_GetString(objv[2]);

	// paranoid of buffer overflow
	if (strlen(s) > 200) {
		Tcl_Obj *str = Tcl_ObjPrintf("not encrypting due to length");
		Tcl_SetObjResult(interp, str);
		return TCL_ERROR;
	}

	char encrypted[800];
	encrypt_string(key, s, encrypted, strlen(s));
	encrypted[512] = '\0';

	Tcl_Obj *ret = Tcl_NewStringObj(encrypted, strlen(encrypted));
	Tcl_SetObjResult(interp, ret);

	return TCL_OK;
}

static int
Decrypt_Cmd(ClientData cdata, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {
	if (objc != 3) {
		Tcl_Obj *str = Tcl_ObjPrintf("wrong # args: should be \"decrypt key string\"");
		Tcl_SetObjResult(interp, str);
		return TCL_ERROR;
	}

	const char *key = Tcl_GetString(objv[1]);
	const char *s = Tcl_GetString(objv[2]);

	// paranoid of buffer overflow
	if (strlen(s) > 200) {
		Tcl_Obj *str = Tcl_ObjPrintf("not decrypting due to length");
		Tcl_SetObjResult(interp, str);
		return TCL_ERROR;
	}

	char decrypted[1000];
	decrypt_string(key, s, decrypted, strlen(s));
	decrypted[512] = '\0';

	Tcl_Obj *ret = Tcl_NewStringObj(decrypted, strlen(decrypted));
	Tcl_SetObjResult(interp, ret);

	return TCL_OK;
}

/*
	Export to Tcl
*/
int DLLEXPORT
Fish_Init(Tcl_Interp *interp) {
	if (Tcl_InitStubs(interp, TCL_VERSION, 0) == NULL) {
		return TCL_ERROR;
	}
	if (Tcl_PkgProvide(interp, "Fish", "1.0") == TCL_ERROR) {
		return TCL_ERROR;
	}
	Tcl_CreateObjCommand(interp, "encrypt", Encrypt_Cmd, NULL, NULL);
	Tcl_CreateObjCommand(interp, "decrypt", Decrypt_Cmd, NULL, NULL);
	return TCL_OK;
}
