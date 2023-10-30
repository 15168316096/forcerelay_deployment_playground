IBCSOLIDITY_DIR = ibc-solidity-contract
FORCERELAY_DIR = forcerelay
FORCERELAY_TOOLS_IBC_TEST_CONTRACTS_DEPLOYMENT = $(FORCERELAY_DIR)/tools/ibc-test/contracts/deployment
CKB_CLI_DIR = ckb-cli
FORCERELAY_CKB_SDK_DIR = forcerelay-ckb-sdk

ckb_cli_install:
	git clone https://github.com/nervosnetwork/ckb-cli.git
	(\
		cd $(CKB_CLI_DIR) && \
		cargo install --path . -f --locked && \
		export API_URL=https://testnet.ckbapp.dev/ && \
		export YOUR_CKB_ADDRESS=`echo -e "123\n123" | ckb-cli account new | grep "testnet:" | awk 'NR==1{print $2}'` \
	)

axon_ibc_deploy:
	git clone https://github.com/synapseweb3/ibc-solidity-contract
	( \
		cd $(IBCSOLIDITY_DIR) && \
		yarn install && \
		yarn compile && \
		AXON_HTTP_RPC_URL=https://rpc-alphanet-axon.ckbapp.dev yarn migrate \
	)

ckb_ibc_deploy:
	git clone https://github.com/synapseweb3/forcerelay
	( \
		echo YOUR_CKB_ADDRESS:${YOUR_CKB_ADDRESS} && \
		cd $(FORCERELAY_TOOLS_IBC_TEST_CONTRACTS_DEPLOYMENT) && \
		mkdir migration && \
		mkdir tx && \
		echo -e "123\n" | ./upload.sh connection https://testnet.ckbapp.dev/ $(YOUR_CKB_ADDRESS) && \
		echo -e "123\n" | ./upload.sh channel https://testnet.ckbapp.dev/ $(YOUR_CKB_ADDRESS) && \
		echo -e "123\n" | ./upload.sh packet https://testnet.ckbapp.dev/ $(YOUR_CKB_ADDRESS) && \
		echo -e "123\n" | ./upload.sh sudt https://testnet.ckbapp.dev/ $(YOUR_CKB_ADDRESS) \
	)

forcerelay_install:
	cd $(FORCERELAY_DIR) && \
	cargo install --path crates/relayer-cli --bin forcerelay \
	# todo modify relayer config.toml

forcerelay_ckb_sdk_install:
	git clone https://github.com/synapseweb3/forcerelay-ckb-sdk
	(\
		cd $(FORCERELAY_CKB_SDK_DIR) && \
		cargo install --path . --example sudt-transfer && \
		sudt-transfer --help \	
		# todo modify sudt-transfer config.toml
	)
	

clean:
	rm -rf $(FORCERELAY_DIR)
	rm -rf $(IBCSOLIDITY_DIR)
	rm -rf $(CKB_CLI_DIR)
	rm -rf $(FORCERELAY_CKB_SDK_DIR)