use std::ffi::CStr;
use std::thread::sleep;
use std::time::Duration;

use pam::constants::PamResultCode::{PAM_AUTH_ERR, PAM_SUCCESS};
use pam::constants::{PAM_TEXT_INFO, PamFlag, PamResultCode};
use pam::conv::Conv;
use pam::module::{PamHandle, PamHooks};
use pam::{pam_hooks, pam_try};
use rand::random;

struct PamRandom;
pam_hooks!(PamRandom);

impl PamHooks for PamRandom {
    fn acct_mgmt(_pamh: &mut PamHandle, _args: Vec<&CStr>, _flags: PamFlag) -> PamResultCode {
        PAM_SUCCESS
    }

    fn sm_authenticate(pamh: &mut PamHandle, args: Vec<&CStr>, _flags: PamFlag) -> PamResultCode {
        let delay = pam_try!(
            args.first()
                .map(|arg| -> Result<Duration, PamResultCode> {
                    Ok(Duration::from_millis(
                        arg.to_str()
                            .map_err(|_e| PAM_AUTH_ERR)?
                            .parse()
                            .map_err(|_e| PAM_AUTH_ERR)?,
                    ))
                })
                .unwrap_or(Ok(Duration::from_millis(0)))
        );
        let conv = match pamh.get_item::<Conv>() {
            Ok(res) => match res {
                Some(conv) => conv,
                _ => todo!(),
            },
            Err(err) => {
                println!("Couldn't get pam_conv");
                return err;
            }
        };
        sleep(delay);
        if random::<bool>() {
            pam_try!(conv.send(PAM_TEXT_INFO, "Randomly succeeded"));
            PAM_SUCCESS
        } else {
            pam_try!(conv.send(PAM_TEXT_INFO, "Randomly failed"));
            PAM_AUTH_ERR
        }
    }
}
