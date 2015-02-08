#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <cutils/sockets.h>
#include "includes.h"
#include "rild_porting.h"
#include <assert.h>

#include "common.h"
#include "config.h"

static uint8  atou8(const char *a)
{
	uint8 ret = 0;
	
	if(*a <= '9' && *a >= '0')
		ret = *a - '0';
	else if(*a >= 'a' && *a <= 'f')
		ret = *a - 'a' + 10;
	else if(*a >= 'A' && *a <= 'F')
		ret = *a - 'A' + 10;

	return ret;
}


//char to uint_8
static  void atohex(const char *a, uint8 *hex)
{
	uint8 tmp = atou8(a);

	tmp <<= 4;
	tmp += atou8(a + 1);

	*hex = tmp;
	
}

static  void strtohex(char *a, uint32 len, uint8 *hex)
{
	int i = 0;
	
	for (i = 0; i < len/2; i++)
		atohex(a + i * 2, hex + i);
}


//uint8 to char
static void hextoa(uint8 *hex, char *a)
{
	sprintf(a, "%2x", *hex);
	
	if(*hex < 0x10){
		*a = '0';
	}
}

static void hextostr(uint8 *hex, uint32 len,
			char *a)
{
	int i = 0;
	
	for(i = 0; i < len; i++)
		hextoa(hex + i, a + i * 2);
}


//Initialization
//create the socket
int connectToRild()
{
	int sock = socket_local_client("rild-debug", 
			ANDROID_SOCKET_NAMESPACE_RESERVED, SOCK_STREAM);
	
	if(sock < 0)
		wpa_printf(MSG_ERROR, "connectToRild %s", strerror(errno));
	
	return sock;
}

int eapRild(int sock, int total)
{
	int ret = -1;
	int Intlen = sizeof(int);
	/*two paras, 1 - case_number(100), 2 - data*/
	int number = 3;
	/*case_number*/
	char buf[] = "100";
	int len = strlen(buf);
	/*1.number of paras 2.case 3.total length of data*/
	ret = send(sock, &number, sizeof(int), 0);
	if(ret == sizeof(int))
		ret = send(sock, &len, sizeof(int), 0);
	else 
		return -1;
	if(ret == sizeof(int))
		ret = send(sock, &buf, len, 0);
	else 
		return -2;
	if(ret == len)
		ret = send(sock, &Intlen, sizeof(int), 0);
	else 
		return -3;
	if(ret == sizeof(int))
		ret = send(sock, &total, sizeof(int), 0);
	else 
		return -4;
	if(ret == sizeof(int)) {
		ret = send(sock, &total, sizeof(int), 0);
		return ret;
	}
	else
		return -5;
}
//Input functionName
//1 EAP-SIM
//RAND(len 16)
int eapSimSetParam(int sock, char *aid, int apptype, uint8 *rand)
{
	int ret = -1, strLen = 0, total = 0;
	int aid_len = 0, index = 0,rand_len = SIM_RAND_LEN;
	char *simInput = NULL;
	char retchar[256] = { }; /* for test total*2 */
	int EAP_SIM_FLAG = 0x90001;

	assert(sock > 0);

	if(aid) {
		wpa_printf(MSG_DEBUG, "USIM CARD auth with EAP-SIM\n");
		/*apptype + aid_len + aid(32) + rand_len + rand*/
		strLen = 4 * 2 + AID_LEN + 4 + SIM_RAND_LEN;
		aid_len = AID_LEN;
	} else {
		wpa_printf(MSG_DEBUG, "SIM CARD auth with EAP-SIM\n");
		/*apptype + aid_len + aid(NULL) + rand_len + rand*/
		strLen = 4 * 3 + SIM_RAND_LEN;
		aid_len = 0;
	}
	/*+ Header,Header_len,EAP_SIM_FLAG*/
	total = strLen + 16;

	wpa_printf(MSG_DEBUG, "%s sock %d , %d\n", __FUNCTION__, sock, total);
	wpa_hexdump(MSG_DEBUG, "rand: ", rand, SIM_RAND_LEN);

	simInput = (char *)os_malloc(total);
	if(simInput == NULL)
		return -1;
	os_memset(simInput, 0, total);

	/*HEAD:FLAG:LEN:APP:AID_LEN:AID:RAND_LEN:RAND*/
	os_memcpy(simInput, Header, 8);
	index += Header_len;
	os_memcpy(&simInput[index], &EAP_SIM_FLAG, sizeof(int));
	index += sizeof(int);
	os_memcpy(&simInput[index], &strLen, sizeof(int));
	index += sizeof(int);
	os_memcpy(&simInput[index], &(apptype), sizeof(int));
	index += sizeof(int);
	os_memcpy(&simInput[index], &aid_len, sizeof(int));
	index += sizeof(int);
	os_memcpy(&simInput[index], aid, aid_len);
	index += aid_len;
	os_memcpy(&simInput[index], &rand_len, sizeof(int));
	index += sizeof(int);
	os_memcpy(&simInput[index], rand, SIM_RAND_LEN);

	hextostr(simInput, total, retchar); /*for test*/
	wpa_printf(MSG_DEBUG, "%d ,%s will sent to rild\n", strLen, retchar);
	
	if(eapRild(sock,total) == sizeof(int))
		ret = send(sock, simInput, total, 0);
	else {
		ret = -6;
		goto failed;
	}
	if(ret == total) {
		wpa_printf(MSG_DEBUG, "%s ok\n", __FUNCTION__);
		ret = 0;
	} else
		ret = -7;

failed:	
	free(simInput);
	wpa_printf(MSG_DEBUG, "%s (%d)%s\n", __FUNCTION__, ret, strerror(errno));
	return ret;
}



//2  EAP-AKA
//RAND(16), AUTN(16)
int eapAkaSetParam(int sock, char *aid, int apptype, uint8 *rand, uint8 *autn)
{
	int ret = -1, strLen = 0, total = 0;
	int index = 0, aid_len = AID_LEN, rand_len = AKA_RAND_LEN, autn_len = AKA_AUTN_LEN;
	char *simInput = NULL;
	char retchar[256] = { }; /* for test,total*2 */
	int EAP_USIM_FLAG = 0x90002;

	if(aid == NULL || strncmp(aid, "error", 5) == 0) {
		wpa_printf(MSG_DEBUG, "USIM CARD auth with EAP-SIM,Reason: Aid empty or error\n");
		return ret;
	}
	assert(sock > 0);
	/*apptype + aid_len + aid(32) + rand_len + rand + autn_len + autn*/
	strLen = 4 * 2 + AID_LEN + 4 + SIM_RAND_LEN + 4 + AKA_AUTN_LEN;

	/*+ Header,Header_len,EAP_SIM_FLAG*/
	total = strLen + 16;	
	
	wpa_printf(MSG_DEBUG, "%s sock %d %d\n", __FUNCTION__,sock,total);

	wpa_hexdump(MSG_DEBUG, "rand: ", rand, AKA_RAND_LEN);
	wpa_hexdump(MSG_DEBUG, "autn: ", autn, AKA_AUTN_LEN);

	simInput = (char *)os_malloc(total);
	if(simInput == NULL)
		return -1;
	os_memset(simInput, 0, total);

	/*HEAD:FLAG:LEN:APP:AID_LEN:AID:RAND_LEN:RAND:AUTN_LEN:AUTN*/
	os_memcpy(simInput, Header, 8);
	index += Header_len;
	os_memcpy(&simInput[index], &EAP_USIM_FLAG, sizeof(int));
	index += sizeof(int);
	os_memcpy(&simInput[index], &strLen, sizeof(int));
	index += sizeof(int);
	os_memcpy(&simInput[index], &(apptype), sizeof(int));
	index += sizeof(int);
	os_memcpy(&simInput[index], &aid_len, sizeof(int));
	index += sizeof(int);
	os_memcpy(&simInput[index], aid, aid_len);
	index += aid_len;
	os_memcpy(&simInput[index], &rand_len, sizeof(int));
	index += sizeof(int);
	os_memcpy(&simInput[index], rand, AKA_RAND_LEN);
	index += AKA_RAND_LEN;
	os_memcpy(&simInput[index], &autn_len, sizeof(int));
	index += sizeof(int);
	os_memcpy(&simInput[index], autn, AKA_AUTN_LEN);
	
	hextostr(simInput, total, retchar); /*for test*/
	wpa_printf(MSG_DEBUG, "%d ,%s will sent to rild\n", strLen, retchar);

	if(eapRild(sock,total) == sizeof(int))
		ret = send(sock, simInput, total, 0);
	else {
		ret = -6;
		goto failed;
	}
	if(ret == total) {
		wpa_printf(MSG_DEBUG, "%s ok\n", __FUNCTION__);
		ret = 0;
	} else
		ret = -7;
failed:
	free(simInput);
	wpa_printf(MSG_DEBUG, "%s (%d)%s\n", __FUNCTION__, ret, strerror(errno));

	return ret;
}

static int parseSimResult(char *strParm, int strLen, uint8 *sres, uint8 *kc)
{
	int ret = -1;
	int type = 0; //RESPONSE_SOLICITED 0   RESPONSE_UNSOLICITED 1
	int token = 0; //default
	int err = -1;
	int ret_index = 0;
	int ret_len = 0;
	char ret_char[256] = {};/* for test,total*2 */
	wpa_printf(MSG_DEBUG, "%s \n", __FUNCTION__);
	
	os_memcpy(&type, &strParm[ret_index], sizeof(int));
	ret_index += sizeof(int);
	os_memcpy(&token, &strParm[ret_index], sizeof(int));
	ret_index += sizeof(int);
	os_memcpy(&err, &strParm[ret_index], sizeof(int));
	ret_index += sizeof(int);

	if(err == 0) {
		os_memcpy(&ret_len, &strParm[ret_index], sizeof(int));
		ret_index += sizeof(int);
		if(ret_len == 12){
			/*SIM(2G) EAP-SIM:4BYTE     8BYTE
			 *                sres      kc
			*/
			hextostr(strParm + ret_index ,SIM_SRES_LEN + SIM_KC_LEN, ret_char);
			wpa_printf(MSG_DEBUG, "EAP_SIM with SIMCARD %s\n",ret_char);
			os_memcpy(sres, &strParm[ret_index],SIM_SRES_LEN);
			ret_index += SIM_SRES_LEN;
			os_memcpy(kc, &strParm[ret_index],SIM_KC_LEN);
		} else if(ret_len == 14) {
			/*USIM(3G) EAP-SIM:1BYTE 	4BYTE	1BYTE	 8BYTE
			 *                 sres_len	sres 	kc_len	 kc
			*/
			hextostr(strParm + ret_index ,SIM_SRES_LEN + SIM_KC_LEN + 2, ret_char);
			wpa_printf(MSG_DEBUG, "EAP_SIM with USIMCARD %s\n",ret_char);
			os_memcpy(sres, &strParm[ret_index + 1],SIM_SRES_LEN);
			ret_index += SIM_SRES_LEN + 1;
			os_memcpy(kc, &strParm[ret_index + 1],SIM_KC_LEN);
		}
	} else {
		wpa_printf(MSG_DEBUG, "%d\n", err);
		return -1;
	}

	wpa_printf(MSG_DEBUG, "parseSimResult ok\n");
	wpa_hexdump(MSG_DEBUG, "parseSimResult kc", kc, SIM_KC_LEN);
	wpa_hexdump(MSG_DEBUG, "parseSimResult sres", sres, SIM_SRES_LEN);
	return 0;
}

static int parseAkaResult(char *strParm, int strLen,
			uint8 *res, size_t *res_len,
		     	uint8 *ik, uint8 *ck, uint8 *auts)
{
	int ret = -1;
	int type = 0; //RESPONSE_SOLICITED 0   RESPONSE_UNSOLICITED 1
	int token = 0; //default
	int err = -1;
	int ret_index = 0;
	int ret_len = 0;
	uint8 kc[SIM_KC_LEN];
	char ret_char[256] = {};/* for test,total*2 */

	wpa_printf(MSG_DEBUG, "%s (%d)\n", __FUNCTION__, strLen);
	
	os_memcpy(&type, &strParm[ret_index], sizeof(int));
	ret_index += sizeof(int);
	os_memcpy(&token, &strParm[ret_index], sizeof(int));
	ret_index += sizeof(int);
	os_memcpy(&err, &strParm[ret_index], sizeof(int));
	ret_index += sizeof(int);

	if(err == 0) {
		os_memcpy(&ret_len, &strParm[ret_index], sizeof(int));
		ret_index += sizeof(int);
		
		if(strParm[ret_index] == 0xdb){
			/*USIM(3G) EAP-AKA sucess:1BYTE	          1BYTE      res[BYTE]  1BYTE     CK[BYTE]    1BYTE 	IK[BYTE]  1BYTE     8BYTE
		 	*                         0xdb(success)   res_len    res        CK_len    CK          IK_len    IK        kc_len    kc
			*/
			hextostr(strParm + ret_index ,SIM_SRES_LEN + SIM_KC_LEN, ret_char);
			wpa_printf(MSG_DEBUG, "parseAkaSuccess%s\n",ret_char);
			os_memcpy(res_len, &strParm[ret_index + 1], 1);
			ret_index += 2;
			os_memcpy(res, &strParm[ret_index], *res_len);
			wpa_hexdump(MSG_DEBUG, "parseAkaSuccess res", res, *res_len);
			os_memcpy(ck, &strParm[ret_index + 1], CK_LEN);
			wpa_hexdump(MSG_DEBUG, "parseAkaSuccess ck", ck, CK_LEN);
			ret_index += CK_LEN + 1;
			os_memcpy(ik, &strParm[ret_index + 1], IK_LEN);
			wpa_hexdump(MSG_DEBUG, "parseAkaSuccess ik", ik, IK_LEN);
			ret_index += IK_LEN + 1;
			os_memcpy(kc, &strParm[ret_index + 1], SIM_KC_LEN);
			wpa_hexdump(MSG_DEBUG, "parseAkaSuccess kc", kc, tmpLen);
			
		} else if(strParm[ret_index] == 0xdc) {
			/*USIM(3G) EAP-AKA Synchronisation failure:1BYTE	     1BYTE      AUTS[BYTE]
			*                                          0xdc(failure) AUTS_len   AUTS
			*/
			hextostr(strParm + ret_index ,AKA_AUTS_LEN + 2, ret_char);
			wpa_printf(MSG_DEBUG, "parseAkaFailure auts %s\n",ret_char);
			os_memcpy(auts, &strParm[ret_index + 2],AKA_AUTS_LEN);
			wpa_hexdump(MSG_DEBUG, "parseAkaFailure auts ", auts, AKA_AUTS_LEN);
		}		
		
	} else {
		wpa_printf(MSG_DEBUG, "%d\n", err);
		return -1;
	}
	return 0;
}


//output function

//1 GSM security_parameters context
int eapSimQueryResult(int sock, uint8 *sres, uint8 *kc)
{
	int ret = -1, strLen = 0, Len = 0;
	char *strParm = NULL;

	assert(sres);
	assert(kc);
	assert(sock > 0);

	wpa_printf(MSG_DEBUG,"%s\n", __FUNCTION__);

	ret = recv(sock, &Len, sizeof(int), 0);
	strLen = ntohl(Len);
	wpa_printf(MSG_DEBUG,"ret:%d \t strLen:%d\n", ret,strLen);
	if(sizeof(int) == ret) {
		strParm = (char *)os_malloc(strLen + 1);
		if(strParm == NULL)
			return -1;
		memset(strParm, 0, strLen + 1);
		strParm[strLen] = '\0';
		ret = recv(sock, strParm, strLen, 0);
		if(strLen == ret){
			ret = parseSimResult(strParm, strLen, sres, kc);
		}
		free(strParm);
	}

	return ret;
}




//2 3G security_parameters context
int eapAkaQueryResult(int sock, uint8 *res, size_t *res_len,
		     uint8 *ik, uint8 *ck, uint8 *auts)
{
	int ret = -1, strLen = 0, Len = 0;
	char *strParm = NULL;

	assert(ik);
	assert(ck);
	assert(auts);
	assert(sock > 0);

	wpa_printf(MSG_DEBUG,"%s\n", __FUNCTION__);	
	ret = recv(sock, &Len, sizeof(int), 0);
	strLen = ntohl(Len);
	wpa_printf(MSG_DEBUG,"ret:%d \t strLen:%d\n", ret,strLen);
	if(sizeof(int) == ret){
		strParm = (char *)malloc(strLen + 1);
		if(strParm == NULL)
			return -1;
		memset(strParm, 0, strLen + 1);
		strParm[strLen] = '\0';
		ret = recv(sock, strParm, strLen, 0);
		if(strLen == ret){
			ret = parseAkaResult(strParm, strLen,
						res, res_len,
						ik, ck, auts);
		}
		free(strParm);		
	}

	return ret;
}

//uninitilization;
int disconnectRild(int sock)
{
	int ret;
	
	assert(sock > 0);
	ret = close(sock);
	
	return ret;
}
