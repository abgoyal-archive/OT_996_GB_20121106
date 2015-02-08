
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <cutils/sockets.h>
#include "includes.h"
#include "rild_porting.h"
#include <assert.h>

#include "common.h"
#include "config.h"


typedef enum { SCARD_GSM_SIM, SCARD_USIM } sim_types;

#define SCARDCONTEXT  	void*
#define SCARDHANDLE	void*
#define DWORD 		long

struct scard_data {
	SCARDCONTEXT ctx;
	SCARDHANDLE card;
	DWORD protocol;
	sim_types sim_type;
	int pin1_required;
};

/**
 * scard_init - Initialize SIM/USIM connection using PC/SC
 * @sim_type: Allowed SIM types (SIM, USIM, or both)
 * Returns: Pointer to private data structure, or %NULL on failure
 *
 * This function is used to initialize SIM/USIM connection. PC/SC is used to
 * open connection to the SIM/USIM card and the card is verified to support the
 * selected sim_type. In addition, local flag is set if a PIN is needed to
 * access some of the card functions. Once the connection is not needed
 * anymore, scard_deinit() can be used to close it.
 */
struct scard_data * scard_init(scard_sim_type sim_type)
{
	long ret;
	unsigned long len;
	struct scard_data *scard;
#ifdef CONFIG_NATIVE_WINDOWS
	TCHAR *readers = NULL;
#else /* CONFIG_NATIVE_WINDOWS */
	char *readers = NULL;
#endif /* CONFIG_NATIVE_WINDOWS */
	unsigned char buf[100];
	size_t blen;
	int transaction = 0;
	int pin_needed;

	wpa_printf(MSG_DEBUG, "SCARD: initializing smart card interface");

	wpa_printf(MSG_DEBUG, "%s\n", __FUNCTION__);
	scard = os_zalloc(sizeof(*scard));
	if (scard == NULL)
		return NULL;
	
	scard->sim_type = SCARD_GSM_SIM;
	if (sim_type == SCARD_USIM_ONLY || sim_type == SCARD_TRY_BOTH) {
		wpa_printf(MSG_DEBUG, "SCARD: verifying USIM support");

		scard->sim_type = SCARD_USIM;	
	}
	
	return scard;

}



/**
 * scard_deinit - Deinitialize SIM/USIM connection
 * @scard: Pointer to private data from scard_init()
 *
 * This function closes the SIM/USIM connect opened with scard_init().
 */
void scard_deinit(struct scard_data *scard)
{
	long ret;

	if (scard == NULL)
		return;

	wpa_printf(MSG_DEBUG, "SCARD: deinitializing smart card interface");

	wpa_printf(MSG_DEBUG, "%s\n", __FUNCTION__);
	os_free(scard);
}


static long scard_transmit(struct scard_data *scard,
			   unsigned char *_send, size_t send_len,
			   unsigned char *_recv, size_t *recv_len)
{
	long ret;
	unsigned long rlen;

	wpa_hexdump_key(MSG_DEBUG, "SCARD: scard_transmit: send",
			_send, send_len);

	wpa_printf(MSG_DEBUG, "%s++", __FUNCTION__);
	return 0;
}


/**
 * scard_gsm_auth - Run GSM authentication command on SIM card
 * @scard: Pointer to private data from scard_init()
 * @_rand: 16-byte RAND value from HLR/AuC
 * @sres: 4-byte buffer for SRES
 * @kc: 8-byte buffer for Kc
 * Returns: 0 on success, -1 if SIM/USIM connection has not been initialized,
 * -2 if authentication command execution fails, -3 if unknown response code
 * for authentication command is received, -4 if reading of response fails,
 * -5 if if response data is of unexpected length
 *
 * This function performs GSM authentication using SIM/USIM card and the
 * provided RAND value from HLR/AuC. If authentication command can be completed
 * successfully, SRES and Kc values will be written into sres and kc buffers.
 */
int scard_gsm_auth(char *aid, int apptype, const unsigned char *_rand,
		   unsigned char *sres, unsigned char *kc)
{
	size_t len;
	int sock = -1;
	int ret = 0;

	wpa_hexdump(MSG_DEBUG, "SCARD: GSM auth - RAND", _rand, 16);
	wpa_printf(MSG_DEBUG, "%s++\n", __FUNCTION__);

	sock = connectToRild();
	ret = eapSimSetParam(sock, aid, apptype, _rand);
	if(0 == ret)
		ret = eapSimQueryResult(sock, sres, kc);
	disconnectRild(sock);
	usleep(150 * 1000);

	if(0 != ret)
		return ret;


	wpa_hexdump(MSG_DEBUG, "SCARD: GSM auth - SRES", sres, 4);
	wpa_hexdump(MSG_DEBUG, "SCARD: GSM auth - Kc", kc, 8);

	return 0;
}


/**
 * scard_umts_auth - Run UMTS authentication command on USIM card
 * @scard: Pointer to private data from scard_init()
 * @_rand: 16-byte RAND value from HLR/AuC
 * @autn: 16-byte AUTN value from HLR/AuC
 * @res: 16-byte buffer for RES
 * @res_len: Variable that will be set to RES length
 * @ik: 16-byte buffer for IK
 * @ck: 16-byte buffer for CK
 * @auts: 14-byte buffer for AUTS
 * Returns: 0 on success, -1 on failure, or -2 if USIM reports synchronization
 * failure
 *
 * This function performs AKA authentication using USIM card and the provided
 * RAND and AUTN values from HLR/AuC. If authentication command can be
 * completed successfully, RES, IK, and CK values will be written into provided
 * buffers and res_len is set to length of received RES value. If USIM reports
 * synchronization failure, the received AUTS value will be written into auts
 * buffer. In this case, RES, IK, and CK are not valid.
 */
int scard_umts_auth(char *aid, int apptype, const unsigned char *_rand,
		    const unsigned char *autn,
		    unsigned char *res, size_t *res_len,
		    unsigned char *ik, unsigned char *ck, unsigned char *auts)
{
	size_t len;

	wpa_hexdump(MSG_DEBUG, "SCARD: UMTS auth - RAND", _rand, AKA_RAND_LEN);
	wpa_hexdump(MSG_DEBUG, "SCARD: UMTS auth - AUTN", autn, AKA_AUTN_LEN);

	wpa_printf(MSG_DEBUG, "%s++", __FUNCTION__);
	int sock = -1;
	int ret = -1;

	sock = connectToRild();
	ret = eapAkaSetParam(sock, aid, apptype, _rand, autn);
	if(0 == ret)
		ret = eapAkaQueryResult(sock, res, res_len,
			ik, ck, auts);
	disconnectRild(sock);
	usleep(150 * 1000);

	if(0 != ret)
		return ret;
	return 0;

}
