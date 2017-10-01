import EtherKit
import PromiseKit
import Alamofire
import PMKAlamofire
import ABIKit
import Gloss

let version = 1 as UInt8

public enum NetworkId: UInt {
    case None = 0x00
    case Homestead = 0x01
    case Ropsten = 0x03
    case Rinkeby = 0x04
    case Kovan = 0x2a
    case CareChain = 0xA18E
    case Local = 0xff
}

public enum BlockTag: Int {
    case pending = -2
    case latest = -1
    case earliest = 0
}

public func networkInterface(_ networkId: NetworkId) -> [String]
{
    switch (networkId)
    {
    case .None, .CareChain:
        return ["https://testnet.carechain.io:8545","0xf7548c1b3aa7d52ef1a03baeea96231d8a96f8a4","0x2a568930ca544eff2d80c761d435de29501cd742", "http://139.59.139.169:3000/api/v1/account/$ADDRESS/fund",".post"]
    case .Homestead:
        return ["https://homestead.infura.io","","0xab5c8051b9a1df1aab0149f8b0630848b7ecabf6","",""]
    case .Kovan:
        return ["https://kovan.infura.io","0xd36ea9fa1235763e25cfc6625a55cc2a3a3b7556","0x5f8e9351dc2d238fb878b6ae43aa740d62fc9758","",""]
   case .Ropsten:
        return ["https://ropsten.infura.io","","0x41566e3a081f5032bdcad470adb797635ddfe1f0","http://faucet.ropsten.be:3001/donate/$ADDRESS",".get"]
    case .Rinkeby:
        return ["https://rinkeby.infura.io","0x7c338672f483795eca47106dc395660d95041dbe","0x2cc31912b2b0f3075a87b3640923d45a26cef3ee","",""]
    case .Local:
        return ["https://127.0.0.1:8545","","0x2a568930ca544eff2d80c761d435de29501cd742","",""]
    default:
        return ["https://testnet.carechain.io:8545","0xf7548c1b3aa7d52ef1a03baeea96231d8a96f8a4","0x2a568930ca544eff2d80c761d435de29501cd742","http://139.59.139.169:3000/api/v1/account/$ADDRESS/fund",".post"]
    }
}


public class IpcClient {
    
    var transactionNonce:UInt = 0
    
    public init?() {
    }

    func printBody(response: Alamofire.DataResponse<Any>)
    {
        if let requestBody = response.request?.httpBody {
            do {
                let jsonArray = try JSONSerialization.jsonObject(with: requestBody, options: [])
                print("Array: \(jsonArray)")
            }
            catch {
                print("Error: \(error)")
            }
        }
    }
    
    public func getBlockTag(blockTag: BlockTag) -> String
    {
        switch(blockTag) {
            case .earliest:
                return "earliest"
            case .latest:
                return "latest"
            case .pending:
                return "pending"
            default:
                return BigNumber(integer: blockTag.hashValue).hexString
        }
    }
    /**
     Returns the current client version.
     
     @return String - The current client version
     */
    public func web3_clientVersion(netId: NetworkId) -> Promise<String>
    {
        return Promise<String> { fulfill, reject in
            Alamofire.request(networkInterface(netId)[0], method: .post,  parameters: [
                "jsonrpc": "2.0" ,
                "method": "web3_clientVersion",
                "id": NSNumber(value: 42),
                "params": []
                ], encoding: JSONEncoding.default )
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        let jdata = queryPath(response.data! as NSObject,"json/json") as? NSDictionary
                        let result = jdata?["result"]
                        if let version = result as? String {
                            fulfill(version)
                        } else {
                            let err = NSError(domain: "XClaim", code: 1, userInfo: [NSLocalizedDescriptionKey: "web3_clientVersion"])
                            reject(err)
                        }
                    case .failure(let error):
                        reject(error)
                    }
            }
        }
    }
    /**
     Returns Keccak-256 (not the standardized SHA3-256) of the given data.
     @param data                the data to convert into a SHA3 hash
     
     @return String - The SHA3 result of the given string.
     */
    public func web3_sha3(netId: NetworkId,data: Data) -> Promise<String>
    {
        return Promise<String> { fulfill, reject in
            Alamofire.request(networkInterface(netId)[0], method: .post,  parameters: [
                "jsonrpc": "2.0" ,
                "method": "web3_sha3",
                "id": NSNumber(value: 42),
                "params": [data]
                ], encoding: JSONEncoding.default )
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        let jdata = queryPath(response.data! as NSObject,"json/json") as? NSDictionary
                        let result = jdata?["result"]
                        if let sha3 = result as? String {
                            fulfill(sha3)
                        } else {
                            let err = NSError(domain: "XClaim", code: 1, userInfo: [NSLocalizedDescriptionKey: "web3_sha3"])
                            reject(err)
                        }
                    case .failure(let error):
                        reject(error)
                    }
            }
        }
    }
    /**
     Returns the current network id.
     
     @return String - The current network id.
     */
    public func net_version(netId: NetworkId) -> Promise<String>
    {
        return Promise<String> { fulfill, reject in
            Alamofire.request(networkInterface(netId)[0], method: .post,  parameters: [
                "jsonrpc": "2.0" ,
                "method": "net_version",
                "id": NSNumber(value: 42),
                "params": []
                ], encoding: JSONEncoding.default )
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        let jdata = queryPath(response.data! as NSObject,"json/json") as? NSDictionary
                        let result = jdata?["result"]
                        if let version = result as? String {
                            fulfill(version)
                        } else {
                            let err = NSError(domain: "XClaim", code: 1, userInfo: [NSLocalizedDescriptionKey: "net_version"])
                            reject(err)
                        }
                    case .failure(let error):
                        reject(error)
                    }
            }
        }
    }
    /**
     Returns true if client is actively listening for network connections.
     
     @return Bool - true when listening, otherwise false.
     */
    public func net_listening(netId: NetworkId) -> Promise<Bool>
    {
        return Promise<Bool> { fulfill, reject in
            Alamofire.request(networkInterface(netId)[0], method: .post,  parameters: [
                "jsonrpc": "2.0" ,
                "method": "net_version",
                "id": NSNumber(value: 42),
                "params": []
                ], encoding: JSONEncoding.default )
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        let jdata = queryPath(response.data! as NSObject,"json/json") as? NSDictionary
                        let result = jdata?["result"]
                        if let listening = result as? Bool {
                            fulfill(listening)
                        } else {
                            let err = NSError(domain: "XClaim", code: 1, userInfo: [NSLocalizedDescriptionKey: "net_listening"])
                            reject(err)
                        }
                    case .failure(let error):
                        reject(error)
                    }
            }
        }
    }
    /**
    Returns number of peers currently connected to the client.
    
    @return Int - integer of the number of connected peers.
    */
    public func net_peerCount(netId: NetworkId) -> Promise<Int>
    {
        return Promise<Int> { fulfill, reject in
            Alamofire.request(networkInterface(netId)[0], method: .post,  parameters: [
                "jsonrpc": "2.0" ,
                "method": "net_peerCount",
                "id": NSNumber(value: 42),
                "params": []
                ], encoding: JSONEncoding.default )
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        let jdata = queryPath(response.data! as NSObject,"json/json") as? NSDictionary
                        let result = jdata?["result"] as! String
                        let start = result.startIndex
                        let ind = result.index(start, offsetBy: 2)
                        let hexa = result.substring(from: ind)
                        if let count = Int(hexa, radix: 16) {
                            fulfill(count)
                        } else {
                            let err = NSError(domain: "XClaim", code: 1, userInfo: [NSLocalizedDescriptionKey: "net_peerCount"])
                            reject(err)
                        }
                    case .failure(let error):
                        reject(error)
                    }
            }
        }
    }
    /**
     Returns the current ethereum protocol version.
     
     @return String - The current ethereum protocol version
     */
    public func eth_protocolVersion(netId: NetworkId) -> Promise<String>
    {
        return Promise<String> { fulfill, reject in
            Alamofire.request(networkInterface(netId)[0], method: .post,  parameters: [
                "jsonrpc": "2.0" ,
                "method": "eth_protocolVersion",
                "id": NSNumber(value: 42),
                "params": []
                ], encoding: JSONEncoding.default )
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        let jdata = queryPath(response.data! as NSObject,"json/json") as? NSDictionary
                        let result = jdata?["result"]
                        if let version = result as? String {
                            fulfill(version)
                        } else {
                            let err = NSError(domain: "XClaim", code: 1, userInfo: [NSLocalizedDescriptionKey: "eth_protocolVersion"])
                            reject(err)
                        }
                    case .failure(let error):
                        reject(error)
                    }
            }
        }
    }
    /**
    Returns an object with data about the sync status or false
     
     @return NSDictionary|Bool, FALSE, when not syncing or an object with sync status data:
        {
        startingBlock: QUANTITY - The block at which the import started (will only be reset, after the sync reached his head)
        currentBlock: QUANTITY  - The current block, same as eth_blockNumber
        highestBlock: QUANTITY - The estimated highest block
        }
     */
    public func eth_syncing(netId: NetworkId) -> Promise<Any>
    {
        return Promise<Any> { fulfill, reject in
            Alamofire.request(networkInterface(netId)[0], method: .post,  parameters: [
                "jsonrpc": "2.0" ,
                "method": "eth_syncing",
                "id": NSNumber(value: 42),
                "params": []
                ], encoding: JSONEncoding.default )
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        let jdata = queryPath(response.data! as NSObject,"json/json") as? NSDictionary
                        let result = jdata?["result"]
                        if let syncing = result as? Bool {
                            fulfill(syncing)
                        } else if let object = result as? NSDictionary {
                            fulfill(object)
                        } else {
                            let err = NSError(domain: "XClaim", code: 1, userInfo: [NSLocalizedDescriptionKey: "eth_syncing"])
                            reject(err)
                        }
                    case .failure(let error):
                        reject(error)
                    }
            }
        }
    }
    /**
     Returns the client coinbase address.
     
     @return DATA, 20 bytes - the current coinbase address.
     */
    public func eth_coinbase(netId: NetworkId) -> Promise<Data>
    {
        return Promise<Data> { fulfill, reject in
            Alamofire.request(networkInterface(netId)[0], method: .post,  parameters: [
                "jsonrpc": "2.0" ,
                "method": "eth_coinbase",
                "id": NSNumber(value: 42),
                "params": []
                ], encoding: JSONEncoding.default )
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        let jdata = queryPath(response.data! as NSObject,"json/json") as? NSDictionary
                        let result = jdata?["result"] as! String
                        if let data = result.data(using: .utf8) {
                            fulfill(data)
                         } else {
                            let err = NSError(domain: "XClaim", code: 1, userInfo: [NSLocalizedDescriptionKey: "eth_coinbase"])
                            reject(err)
                        }
                    case .failure(let error):
                        reject(error)
                    }
            }
        }
    }
    /**
     Returns the client coinbase address.
     
     @return DATA, 20 bytes - the current coinbase address.
     */
    public func eth_mining(netId: NetworkId) -> Promise<Bool>
    {
        return Promise<Bool> { fulfill, reject in
            Alamofire.request(networkInterface(netId)[0], method: .post,  parameters: [
                "jsonrpc": "2.0" ,
                "method": "eth_mining",
                "id": NSNumber(value: 42),
                "params": []
                ], encoding: JSONEncoding.default )
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        let jdata = queryPath(response.data! as NSObject,"json/json") as? NSDictionary
                        let result = jdata?["result"]
                        if let mining = result as? Bool {
                            fulfill(mining)
                        } else {
                            let err = NSError(domain: "XClaim", code: 1, userInfo: [NSLocalizedDescriptionKey: "eth_mining"])
                            reject(err)
                        }
                    case .failure(let error):
                        reject(error)
                    }
            }
        }
    }
    /**
     Returns the number of hashes per second that the node is mining with.
     
     @return QUANTITY - number of hashes per second.
     */
    public func eth_hashrate(netId: NetworkId) -> Promise<Int>
    {
        return Promise<Int> { fulfill, reject in
            Alamofire.request(networkInterface(netId)[0], method: .post,  parameters: [
                "jsonrpc": "2.0" ,
                "method": "eth_hashrate",
                "id": NSNumber(value: 42),
                "params": []
                ], encoding: JSONEncoding.default )
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        let jdata = queryPath(response.data! as NSObject,"json/json") as? NSDictionary
                        let result = jdata?["result"]
                        
                        if let bn = BigNumber(hexString: result as! String) {
                           fulfill(bn.integerValue)
                        } else {
                            let err = NSError(domain: "XClaim", code: 1, userInfo: [NSLocalizedDescriptionKey: "eth_hashrate"])
                            reject(err)
                        }
                    case .failure(let error):
                        reject(error)
                    }
            }
        }
    }
    /**
     Returns the current price per gas in wei.
     
     @return QUANTITY - integer of the current gas price in wei.
     */
    public func eth_getGasPrice(netId: NetworkId) -> Promise<BigNumber>
    {
        return Promise<BigNumber> { fulfill, reject in
            Alamofire.request(networkInterface(netId)[0], method: .post,  parameters: [
                "jsonrpc": "2.0" ,
                "method": "eth_gasPrice",
                "id": NSNumber(value: 42),
                "params": []
                ], encoding: JSONEncoding.default )
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        let jdata = queryPath(response.data! as NSObject,"json/json") as? NSDictionary
                        let result = jdata?["result"]
                        if let bn = BigNumber(hexString: result as! String) {
                            fulfill(bn)
                        } else {
                            let err = NSError(domain: "XClaim", code: 1, userInfo: [NSLocalizedDescriptionKey: "eth_getGasPrice"])
                            reject(err)
                        }
                    case .failure(let error):
                        reject(error)
                    }
            }
        }
    }
    /**
     Returns a list of addresses owned by client.
     
     @return Array of DATA, 20 Bytes - addresses owned by the client..
     */
    public func eth_accounts(netId: NetworkId) -> Promise<Array<Data>>
    {
        return Promise<Array<Data>> { fulfill, reject in
            Alamofire.request(networkInterface(netId)[0], method: .post,  parameters: [
                "jsonrpc": "2.0" ,
                "method": "eth_accounts",
                "id": NSNumber(value: 42),
                "params": []
                ], encoding: JSONEncoding.default )
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        let jdata = queryPath(response.data! as NSObject,"json/json") as? NSDictionary
                        let result = jdata?["result"]
                        if let accounts = result as? [Data]  {
                            fulfill(accounts)
                        } else {
                            let err = NSError(domain: "XClaim", code: 1, userInfo: [NSLocalizedDescriptionKey: "eth_accounts"])
                            reject(err)
                        }
                    case .failure(let error):
                        reject(error)
                    }
            }
        }
    }
    /**
     Returns the number of most recent block.
     
     @return QUANTITY - integer of the current block number the client is on.
     */
    public func eth_getBlockNumber(netId: NetworkId) -> Promise<Int>
    {
        return Promise<Int> { fulfill, reject in
            Alamofire.request(networkInterface(netId)[0], method: .post,  parameters: [
                "jsonrpc": "2.0" ,
                "method": "eth_blockNumber",
                "id": NSNumber(value: 42),
                "params": []
                ], encoding: JSONEncoding.default )
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        let jdata = queryPath(response.data! as NSObject,"json/json") as? NSDictionary
                        let result = jdata?["result"]
                        if let bn = BigNumber(hexString: result as! String) {
                            fulfill(bn.integerValue)
                        } else {
                            let err = NSError(domain: "XClaim", code: 1, userInfo: [NSLocalizedDescriptionKey: "eth_getBlockNumber"])
                            reject(err)
                        }
                    case .failure(let error):
                        reject(error)
                    }
            }
        }
    }
    /**
     Returns the balance of the account of given address.
     
     @param address DATA        20 Bytes - address to check for balance. 
     
     @return QUANTITY - integer of the current balance in wei.
     */
    public func eth_getBalance(netId: NetworkId,address: Address) -> Promise<BigNumber>
    {
        return eth_getBalance(netId: netId ,address: address, tag: .latest)
    }
    /**
     Returns the balance of the account of given address.
     
     @param address DATA        20 Bytes - address to check for balance.
     @param tag QUANTITY|TAG    integer block number, or the string "latest", "earliest" or "pending"

     @return QUANTITY - integer of the current balance in wei.
     */
    public func eth_getBalance(netId: NetworkId, address: Address, tag: BlockTag) -> Promise<BigNumber>
    {
        return Promise<BigNumber> { fulfill, reject in
            Alamofire.request(networkInterface(netId)[0], method: .post,  parameters: [
            "jsonrpc": "2.0" ,
            "method": "eth_getBalance",
            "id": NSNumber(value: 42),
            "params": [address.checksumAddress, getBlockTag(blockTag: tag)]
            ], encoding: JSONEncoding.default )
            .validate()
            .responseJSON { response in
                switch response.result {
                    case .success:
                        let jdata = queryPath(response.data! as NSObject,"json/json") as? NSDictionary
                        let result = jdata?["result"]
                            
                        if let bn = BigNumber(hexString: result as! String) {
                            fulfill(bn)
                        } else {
                            let err = NSError(domain: "XClaim", code: 1, userInfo: [NSLocalizedDescriptionKey: "eth_getBalance"])
                            reject(err)
                        }
                    case .failure(let error):
                        reject(error)
                }
            }
        }
    }
    /**
     Returns the value from a storage position at a given address.
     
     @param address DATA,20 Bytes           address of the storage.
     @param position QUANTITY               integer of the position in the storage.
     @param tag QUANTITY|TAG                integer block number, or the string "latest", "earliest" or "pending"
     
     @return DATA - the value at this storage position.
     */
    public func eth_getStorageAt(netId: NetworkId,address: Address, position: Int, tag: BlockTag) -> Promise<Data>
    {
        return Promise<Data> { fulfill, reject in
            Alamofire.request(networkInterface(netId)[0], method: .post,  parameters: [
                "jsonrpc": "2.0" ,
                "method": "eth_getStorageAt",
                "id": NSNumber(value: 42),
                "params": [address.checksumAddress, position, getBlockTag(blockTag: tag)]
                ], encoding: JSONEncoding.default )
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        let jdata = queryPath(response.data! as NSObject,"json/json") as? NSDictionary
                        let result = jdata?["result"] as! String
                        if let data = result.data(using: .utf8) {
                            fulfill(data)
                       } else {
                            let err = NSError(domain: "XClaim", code: 1, userInfo: [NSLocalizedDescriptionKey: "eth_getStorageAt"])
                            reject(err)
                        }
                    case .failure(let error):
                        reject(error)
                    }
            }
        }
    }
    /**
     Returns the number of transactions *sent* from an address.
     
     @param address DATA,20 Bytes       address to check for balance.
     
     @return QUANTITY - integer of the number of transactions send from this address.
     */
    public func eth_getTransactionCount(netId: NetworkId,address: Address) -> Promise<Int>
    {
        return eth_getTransactionCount(netId:netId,address: address, tag: .latest)
    }
    /**
     Returns the balance of the account of given address.
     
     @param address DATA,20 Bytes           address to check for balance.
     @param tag QUANTITY|TAG                integer block number, or the string "latest", "earliest" or "pending"
     
     @return QUANTITY - integer of the number of transactions send from this address.
     */
    public func eth_getTransactionCount(netId: NetworkId,address: Address, tag: BlockTag) -> Promise<Int>
    {
        return Promise<Int> { fulfill, reject in
            Alamofire.request(networkInterface(netId)[0], method: .post,  parameters: [
                "jsonrpc": "2.0" ,
                "method": "eth_getTransactionCount",
                "id": NSNumber(value: 42),
                "params": [address.checksumAddress,getBlockTag(blockTag: tag)]
                ], encoding: JSONEncoding.default )
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        let jdata = queryPath(response.data! as NSObject,"json/json") as? NSDictionary
                        let result = jdata?["result"]
                        if let bn = BigNumber(hexString: result as! String) {
                            fulfill(bn.integerValue)
                        } else {
                            let err = NSError(domain: "XClaim", code: 1, userInfo: [NSLocalizedDescriptionKey: "eth_getTransactionCount"])
                            reject(err)
                        }
                    case .failure(let error):
                        reject(error)
                    }
            }
        }
    }
    /**
     Returns the number of transactions in a block from a block matching the given block hash.
     
     @param hash DATA,32 Bytes           hash of a block
     
     @return QUANTITY - integer of the number of transactions in this block.
     */
    public func eth_getBlockTransactionCountByHash(netId: NetworkId,hash: Hash) -> Promise<Int>
    {
        return Promise<Int> { fulfill, reject in
            Alamofire.request(networkInterface(netId)[0], method: .post,  parameters: [
                "jsonrpc": "2.0" ,
                "method": "eth_getBlockTransactionCountByHash",
                "id": NSNumber(value: 42),
                "params": [hash]
                ], encoding: JSONEncoding.default )
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        let jdata = queryPath(response.data! as NSObject,"json/json") as? NSDictionary
                        let result = jdata?["result"]
                        if let bn = BigNumber(hexString: result as! String) {
                            fulfill(bn.integerValue)
                        } else {
                            let err = NSError(domain: "XClaim", code: 1, userInfo: [NSLocalizedDescriptionKey: "eth_getBlockTransactionCountByHash"])
                            reject(err)
                        }
                    case .failure(let error):
                        reject(error)
                    }
            }
        }
    }
    /**
     Returns the number of transactions in a block from a block matching the given block number.
     
     @param tag QUANTITY|TAG                integer block number, or the string "latest", "earliest" or "pending"
     
     @return QUANTITY - integer of the number of transactions in this block.
     */
    public func eth_getBlockTransactionCountByNumber(netId: NetworkId,tag: BlockTag) -> Promise<Int>
    {
        return Promise<Int> { fulfill, reject in
            Alamofire.request(networkInterface(netId)[0], method: .post,  parameters: [
                "jsonrpc": "2.0" ,
                "method": "eth_getBlockTransactionCountByNumber",
                "id": NSNumber(value: 42),
                "params": [tag]
                ], encoding: JSONEncoding.default )
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        let jdata = queryPath(response.data! as NSObject,"json/json") as? NSDictionary
                        let result = jdata?["result"]
                        if let bn = BigNumber(hexString: result as! String) {
                            fulfill(bn.integerValue)
                        } else {
                            let err = NSError(domain: "XClaim", code: 1, userInfo: [NSLocalizedDescriptionKey: "eth_getBlockTransactionCountByNumber"])
                            reject(err)
                        }
                    case .failure(let error):
                        reject(error)
                    }
            }
        }
    }
    /**
     Returns the number of transactions in a block from a block matching the given block hash.
     
     @param hash DATA,32 Bytes           hash of a block
     
     @return QUANTITY -  integer of the number of uncles in this block.
     */
    public func eth_getUncleCountByBlockHash(netId: NetworkId,hash: Hash) -> Promise<Int>
    {
        return Promise<Int> { fulfill, reject in
            Alamofire.request(networkInterface(netId)[0], method: .post,  parameters: [
                "jsonrpc": "2.0" ,
                "method": "eth_getUncleCountByBlockHash",
                "id": NSNumber(value: 42),
                "params": [hash]
                ], encoding: JSONEncoding.default )
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        let jdata = queryPath(response.data! as NSObject,"json/json") as? NSDictionary
                        let result = jdata?["result"]
                        if let bn = BigNumber(hexString: result as! String) {
                            fulfill(bn.integerValue)
                        } else {
                            let err = NSError(domain: "XClaim", code: 1, userInfo: [NSLocalizedDescriptionKey: "eth_getUncleCountByBlockHash"])
                            reject(err)
                        }
                    case .failure(let error):
                        reject(error)
                    }
            }
        }
    }
    /**
     Returns the number of uncles in a block from a block matching the given block number.
     
     @param tag QUANTITY|TAG                integer block number, or the string "latest", "earliest" or "pending"
     
     @return QUANTITY - integer of the number of transactions in this block.
     */
    public func eth_getUncleCountByBlockNumber(netId: NetworkId,tag: BlockTag) -> Promise<Int>
    {
        return Promise<Int> { fulfill, reject in
            Alamofire.request(networkInterface(netId)[0], method: .post,  parameters: [
                "jsonrpc": "2.0" ,
                "method": "eth_getUncleCountByBlockNumber",
                "id": NSNumber(value: 42),
                "params": [tag]
                ], encoding: JSONEncoding.default )
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        let jdata = queryPath(response.data! as NSObject,"json/json") as? NSDictionary
                        let result = jdata?["result"]
                        if let bn = BigNumber(hexString: result as! String) {
                            fulfill(bn.integerValue)
                        } else {
                            let err = NSError(domain: "XClaim", code: 1, userInfo: [NSLocalizedDescriptionKey: "eth_getUncleCountByBlockNumber"])
                            reject(err)
                        }
                    case .failure(let error):
                        reject(error)
                    }
            }
        }
    }
    /**
     Returns code at a given address.
     
     @param address DATA,20 Bytes           address to check for balance.
     @param tag QUANTITY|TAG                integer block number, or the string "latest", "earliest" or "pending"
     
      @return DATA - the code from the given address.
     */
    public func eth_getCode(netId: NetworkId,address: Address, tag: BlockTag) -> Promise<Data>
    {
        return Promise<Data> { fulfill, reject in
            Alamofire.request(networkInterface(netId)[0], method: .post,  parameters: [
            "jsonrpc": "2.0" ,
            "method": "eth_getCode",
            "id": NSNumber(value: 42),
            "params": [address.checksumAddress,getBlockTag(blockTag: tag)]
            ], encoding: JSONEncoding.default )
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success:
                    let jdata = queryPath(response.data! as NSObject,"json/json") as? NSDictionary
                    let result = jdata?["result"] as! String
                    if let code = result.data(using: .utf8) {
                        fulfill(code)
                    } else {
                        let err = NSError(domain: "XClaim", code: 1, userInfo: [NSLocalizedDescriptionKey: "eth_getCode"])
                        reject(err)
                    }
                case .failure(let error):
                    reject(error)
                }
            }
        }
    }

    public func eth_estimateGas(netId: NetworkId, transaction: Transaction) -> Promise<BigNumber>
    {
        return Promise<BigNumber> { fulfill, reject in
            Alamofire.request(networkInterface(netId)[0], method: .post,  parameters: [
            "jsonrpc": "2.0" ,
            "method": "eth_estimateGas",
            "id": NSNumber(value: 42),
            "params": [ transactionObject(transaction), getBlockTag(blockTag: .latest)]
            ],encoding: JSONEncoding.default )
            .validate()
            .responseJSON { response in
                switch response.result {
                    case .success:
                        let jdata = queryPath(response.data! as NSObject,"json/json") as? NSDictionary
                        let result = jdata?["result"]
                        
                        if let bn = BigNumber(hexString: result as! String) {
                            fulfill(bn)
                        } else {
                            let err = NSError(domain: "XClaim", code: 1, userInfo: [NSLocalizedDescriptionKey: "eth_estimateGas"])
                            reject(err)
                        }
                    case .failure(let error):
                        reject(error)
                }
            }
        }
    }
    
    public func eth_sign(netId: NetworkId, address: Address, data: Data) -> Promise<String>
    {
        return Promise<String> { fulfill, reject in
            Alamofire.request(networkInterface(netId)[0], method: .post,  parameters: [
                "jsonrpc": "2.0" ,
                "method": "eth_sign",
                "id": NSNumber(value: 42),
                "params": [address.checksumAddress,data]
                ], encoding: JSONEncoding.default )
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        let jdata = queryPath(response.data! as NSObject,"json/json") as? NSDictionary
                        
                        if let result = jdata?["result"] as? String {
                            fulfill(result)
                        } else {
                            let err = NSError(domain: "XClaim", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not Sign Message"])
                            reject(err)
                        }
                    case .failure(let error):
                        reject(error)
                    }
            }
        }
    }

    public func eth_getTransactionReceipt(netId: NetworkId, hash: Hash) -> Promise<TransactionReceipt>
    {
        return Promise<TransactionReceipt> { fulfill, reject in
            Alamofire.request(networkInterface(netId)[0], method: .post,  parameters: [
            "jsonrpc": "2.0" ,
            "method": "eth_getTransactionReceipt",
            "id": NSNumber(value: 42),
            "params": [hash.hexString]
            ], encoding: JSONEncoding.default )
            .validate()
            .responseJSON { response in
                switch response.result {
                    case .success:
                        let jdata = queryPath(response.data! as NSObject,"json/json") as? NSDictionary
                        let result = jdata?["result"]
                            
                        if result is NSNull {
                            reject(NSError.cancelledError())
                        } else if let transactionReceipt = TransactionReceipt(from: result as! [AnyHashable : Any]) {
                            if (transactionReceipt.blockNumber)>0 {
                                fulfill(transactionReceipt)
                            }
                        }
                    case .failure(let error):
                        reject(error)
                }
            }
        }
    }

    public func eth_getTransaction(netId: NetworkId, hash: Hash) -> Promise<TransactionInfo>
    {
        return Promise<TransactionInfo> { fulfill, reject in
            Alamofire.request(networkInterface(netId)[0], method: .post,  parameters: [
            "jsonrpc": "2.0" ,
            "method": "eth_getTransactionByHash",
            "id": NSNumber(value: 42),
            "params": [hash.hexString]
            ], encoding: JSONEncoding.default )
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success:
                    let jdata = queryPath(response.data! as NSObject,"json/json") as? NSDictionary
                    let result = jdata?["result"]
                            
                    if result is NSNull {
                        reject(NSError.cancelledError())
                    } else if let transactionInfo = TransactionInfo(from: result as! [AnyHashable : Any]) {
                         if (transactionInfo.blockNumber)>0 {
                            fulfill(transactionInfo)
                        }
                    }
                case .failure(let error):
                    reject(error)
                }
            }
        }
    }
    
    public func eth_getBlockByNumber(netId: NetworkId, blockNumber: Int, fullList: Bool) -> Promise<BlockInfo>
    {
        return Promise<BlockInfo> { fulfill, reject in
            
            let bn = "0x" + String(format: "%2X", blockNumber)
            Alamofire.request(networkInterface(netId)[0], method: .post,  parameters: [
                "jsonrpc": "2.0" ,
                "method": "eth_getBlockByNumber",
                "id": NSNumber(value: 42),
                "params": [bn, fullList]
                ], encoding: JSONEncoding.default )
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        let jdata = queryPath(response.data! as NSObject,"json/json") as? NSDictionary
                        let result = jdata?["result"]
                         if let res = result as? [AnyHashable : Any], let blockInfo = BlockInfo(from: res) {
                            fulfill(blockInfo)
                        } else {
                            let err = NSError(domain: "XClaim", code: 1, userInfo: [NSLocalizedDescriptionKey: "eth_getBlockByNumber" + (jdata?["error"] as! String)])
                            reject(err)
                        }
                    case .failure(let error):
                        reject(error)
                    }
            }
        }
    }

    public func eth_getBlockByHash(netId: NetworkId, blockHash: Hash, fullList:Bool) -> Promise<BlockInfo>
    {
        return Promise<BlockInfo> { fulfill, reject in
            Alamofire.request(networkInterface(netId)[0], method: .post,  parameters: [
            "jsonrpc": "2.0" ,
            "method": "eth_getBlockByHash",
            "id": NSNumber(value: 42),
            "params": [blockHash.hexString, fullList]
            ], encoding: JSONEncoding.default )
            .validate()
            .responseJSON { response in
                switch response.result {
                    case .success:
                        let jdata = queryPath(response.data! as NSObject,"json/json") as? NSDictionary
                        let result = jdata?["result"]
                            
                        if result is NSNull {
                            reject(NSError.cancelledError())
                        } else if let blockInfo = BlockInfo(from: result as! [AnyHashable : Any]) {
                            fulfill(blockInfo)
                        } else {
                            reject(NSError.cancelledError())
                        }
                    case .failure(let error):
                        reject(error)
                }
            }
        }
    }
 
    public func eth_compileSolidity(netId: NetworkId, code: String) -> Promise<String>
    {
        return Promise<String> { fulfill, reject in
            Alamofire.request(networkInterface(netId)[0], method: .post,  parameters: [
                "jsonrpc": "2.0" ,
                "method": "eth_compileSolidity",
                "id": NSNumber(value: 42),
                "params": [code]
                ], encoding: JSONEncoding.default )
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        let jdata = queryPath(response.data! as NSObject,"json/json") as? NSDictionary
                        
                        let result = jdata?["result"]
                        
                        if let code = result as? String {
                            fulfill(code)
                        } else {
                            let err = NSError(domain: "XClaim", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not Compile Solidity"])
                            reject(err)
                        }
                    case .failure(let error):
                        reject(error)
                    }
            }
        }
    }

    public func eth_getBlockByBlockTag(netId: NetworkId, blockTag: BlockTag, fullList: Bool) -> Promise<BlockInfo>
    {
        return Promise<BlockInfo> { fulfill, reject in

            Alamofire.request(networkInterface(netId)[0], method: .post,  parameters: [
            "jsonrpc": "2.0" ,
            "method": "eth_getBlockByTag",
            "id": NSNumber(value: 42),
            "params": [getBlockTag(blockTag: blockTag) , fullList]
            ], encoding: JSONEncoding.default )
            .validate()
            .responseJSON { response in
                switch response.result {
                    case .success:
                        let jdata = queryPath(response.data! as NSObject,"json/json") as? NSDictionary
                        let result = jdata?["result"]
                        
                        if result is NSNull {
                            reject(NSError.cancelledError())
                        } else if let blockInfo = BlockInfo(from: result as! [AnyHashable : Any]) {
                            fulfill(blockInfo)
                        } else {
                            reject(NSError.cancelledError())
                        }
                    case .failure(let error):
                        reject(error)
                }
            }
        }
    }

    // The setters call sendTransaction
    public func callContract(netId: NetworkId, address: Address, contractName: String, methodName: String, parameterValues: [String], contractAddress: Address?) -> Promise<String>
    {
        return Promise<Transaction> { fulfill, reject in
            
            if let contractData = readJson(fileName: "contracts/"+contractName) , let contractInterface = Contract(data: contractData) {
                
                let trans = Transaction(from: address )
                trans.chainId = ChainId(rawValue: 0x00) // needs to be refactored!
                
                if contractAddress != nil { // transact with an already deployed contract
                    trans.toAddress = contractAddress
                    
                    if let method = contractInterface.find(name: methodName) {
                        //print("parameterValues ",parameterValues)
                        let str = method.encode(values: parameterValues)
                        //print("Encoded method call", str)
                        let sec = SecureData(hexString: str)
                        trans.data = (sec?.data())!
                    }
                }
                fulfill(trans)
            } else {
                let error = NSError(domain: "XClaim", code: 1, userInfo: [NSLocalizedDescriptionKey: "Deploy contract"])
                reject(error)
            }
            }.then {transaction in
                self.eth_call(netId: netId, transaction: transaction)
            }
    }
    
    
    public func eth_call(netId: NetworkId, transaction: Transaction) -> Promise<String>
    {
        
        return Promise<String> { fulfill, reject in
            Alamofire.request(networkInterface(netId)[0], method: .post,  parameters: [
                "jsonrpc": "2.0" ,
                "method": "eth_call",
                "id": NSNumber(value: 42),
                "params": [ transactionObject(transaction), getBlockTag(blockTag: .latest)]
                ],encoding: JSONEncoding.default )
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        //print("response", response)
                        let jdata = queryPath(response.data! as NSObject,"json/json") as? NSDictionary
                        
                        if let result = jdata?["result"] as? String { // , let data = result.data(using: .utf8)
                            fulfill(result)
                        } else {
                            let err = NSError(domain: "XClaim", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not Call"])
                            reject(err)
                        }
                    case .failure(let error):
                        reject(error)
                    }
            }
        }
    }
   
    public func eth_sendTransaction(netId: NetworkId, transaction: Transaction) -> Promise<Hash>
    {
       
        return Promise<Hash> { fulfill, reject in
            
            transaction.nonce = transactionNonce
            transaction.chainId = ChainId(rawValue: 0x00) // needs to be refactored!
            
            print("transaction ", transaction)
            print("transactionObject ", transactionObject(transaction))

            Alamofire.request(networkInterface(netId)[0], method: .post,  parameters: [
                "jsonrpc": "2.0" ,
                "method": "eth_sendTransaction",
                "id": NSNumber(value: 42),
                "params": [ transactionObject(transaction)]
                ],encoding: JSONEncoding.default )
                .validate()
                .responseJSON { response in
                    switch response.result {
                        case .success:
                            
                            //print(response)
                            let jdata = queryPath(response.data! as NSObject,"json/json") as? NSDictionary
                        
                            if let result = jdata?["result"] , let hash = Hash.init(hexString: result as! String) {
                                fulfill(hash)
                            } else {
                                let err = NSError(domain: "XClaim", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not send transaction"])
                                reject(err)
                            }
                        case .failure(let error):
                            reject(error)
                    }
            }
        }
    }
    
    public func eth_sendRawTransaction(netId: NetworkId,unlockedAccount: Account, address: Address, transaction: Transaction) -> Promise<Hash>
    {
        print("eth_sendRawTransaction")
        
        return Promise<Hash> { fulfill, reject in
            if transaction.gasLimit.isZero {
                transaction.gasLimit = BigNumber(decimalString: "350000")
            }
            if transaction.gasPrice.isZero {
                transaction.gasPrice = BigNumber(decimalString: "21000")
                
            }
            transaction.nonce = transactionNonce
            transaction.chainId = ChainId(rawValue: 0x00) // needs to be refactored!
            var rawSignedTransaction:String?
            unlockedAccount.sign(transaction)
            rawSignedTransaction = SecureData.data(toHexString: transaction.serialize())
            Alamofire.request(networkInterface(netId)[0], method: .post,  parameters: [
                "jsonrpc": "2.0" ,
                "method": "eth_sendRawTransaction",
                "id": NSNumber(value: 42),
                "params": [ rawSignedTransaction]
                ],encoding: JSONEncoding.default )
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        print("eth_sendRawTransaction",response)
                        let jdata = queryPath(response.data! as NSObject,"json/json") as? NSDictionary
                        
                        if let result = jdata?["result"] , let hash = Hash.init(hexString: result as! String) {
                            fulfill(hash)
                        } else {
                            let err = NSError(domain: "XClaim", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not send transaction"])
                                reject(err)
                        }
                    case .failure(let error):
                            reject(error)
                    }
            }
        }
    }
    // Whisper
    
    public func shh_version(netId: NetworkId) -> Promise<String>
    {
        return Promise<String> { fulfill, reject in
            Alamofire.request(networkInterface(netId)[0], method: .post,  parameters: [
                "jsonrpc": "2.0" ,
                "method": "shh_version",
                "id": NSNumber(value: 42),
                "params": []
                ],encoding: JSONEncoding.default )
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        let jdata = queryPath(response.data! as NSObject,"json/json") as? NSDictionary
                        let result = jdata?["result"]
                        if let version  = result as? String {
                            fulfill(version)
                        } else {
                            let err = NSError(domain: "XClaim", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not get Whisper version"])
                            reject(err)
                        }
                    case .failure(let error):
                        reject(error)
                    }
            }
        }
    }
    
    public func shh_post(netId: NetworkId, object:NSDictionary) -> Promise<Bool>
    {
        return Promise<Bool> { fulfill, reject in
            Alamofire.request(networkInterface(netId)[0], method: .post,  parameters: [
                "jsonrpc": "2.0" ,
                "method": "shh_post",
                "id": NSNumber(value: 42),
                "params": [object]
                ],encoding: JSONEncoding.default )
                .validate()
                .responseJSON { response in
                switch response.result {
                    case .success:
                        let jdata = queryPath(response.data! as NSObject,"json/json") as? NSDictionary
                        let result = jdata?["result"]
                        if let success  = result as? Bool {
                            fulfill(success)
                        } else {
                            let err = NSError(domain: "XClaim", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not get send Whisper message"])
                            reject(err)
                        }
                    case .failure(let error):
                        reject(error)
                    }
            }
        }
    }
    
    public func shh_newIdentity(netId: NetworkId) -> Promise<Data>
    {
        return Promise<Data> { fulfill, reject in
            Alamofire.request(networkInterface(netId)[0], method: .post,  parameters: [
                "jsonrpc": "2.0" ,
                "method": "shh_newIdentity",
                "id": NSNumber(value: 42),
                "params": []
                ],encoding: JSONEncoding.default )
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        let jdata = queryPath(response.data! as NSObject,"json/json") as? NSDictionary
                        let result = jdata?["result"] as! String
                        if let address = result.data(using: .utf8) {
                            fulfill(address)
                        } else {
                            let err = NSError(domain: "XClaim", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not get create Whisper identity"])
                            reject(err)
                        }
                    case .failure(let error):
                        reject(error)
                    }
            }
        }
    }

    public func shh_hasIdentity(netId: NetworkId) -> Promise<Data>
    {
        return Promise<Data> { fulfill, reject in
            Alamofire.request(networkInterface(netId)[0], method: .post,  parameters: [
                "jsonrpc": "2.0" ,
                "method": "shh_newIdentity",
                "id": NSNumber(value: 42),
                "params": []
                ],encoding: JSONEncoding.default )
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        let jdata = queryPath(response.data! as NSObject,"json/json") as? NSDictionary
                        let result = jdata?["result"] as! String
                        if let address = result.data(using: .utf8) {
                            fulfill(address)
                        } else {
                            let err = NSError(domain: "XClaim", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not get create Whisper identity"])
                            reject(err)
                        }
                    case .failure(let error):
                        reject(error)
                    }
            }
        }
    }

    // convenience
    
    public func eth_getTransactions(netId: NetworkId, address: Address, startBlock: Int) -> Promise<Array<TransactionInfo>>
    {
        var transactionInfos = [TransactionInfo]()
        
        return Promise<Array<TransactionInfo>> { fulfill, reject in
            
            self.eth_getBlockNumber(netId: netId).then { latest -> Void in
                var startAt = latest - 100
                if startBlock > 0 {
                    startAt = startBlock
                }
                var promiseArray =  [Promise<BlockInfo>]()
                for blockNumber in startAt..<latest {
                    let promise = self.eth_getBlockByNumber(netId:netId, blockNumber:blockNumber, fullList: true)
                    promiseArray.append(promise)
                }
                when(fulfilled: promiseArray).then { results -> [TransactionInfo] in
                    for result in results {
                        let blockInfo = result as BlockInfo
                        
                        if let transactions = blockInfo.transactions  as?  [TransactionInfo] {
                            
                            for transaction in transactions {
                                if transaction.fromAddress == address || transaction.toAddress == address {
                                    transactionInfos.append(transaction)
                                }
                            }
                        }
                    }
                    return transactionInfos
                }.catch { error in
                    print(error)
                }
            }
        }
    }
}
