import "@stdlib/deploy";

contract Item with Deployable {
    id: Int as uint64 = 1;
    init(){}

    get fun myAddress(): Address {
        return myAddress();
    }

    get fun otherAddress(): Address {
        let init: StateInit = initOf Item2();
        return contractAddress(init);
    }
}

contract Item2 with Deployable {
    id: Int as uint64 = 2;
    init(){}

    get fun myAddress(): Address {
        return myAddress();
    }

    get fun otherAddress(): Address {
        let init: StateInit = initOf Item();
        return contractAddress(init);
    }
}
message DeployContract {
    id: Int as uint64;
}

contract Item3 with Deployable {
    id: Int as uint64;
    init(id: Int){
        self.id = id;
    }

    get fun myAddress(): Address {
        return myAddress();
    }

    get fun otherAddress(otherId: Int): Address {
        let init: StateInit = initOf Item3(otherId);
        return contractAddress(init);
    }

    receive(msg: DeployContract){
        let init: StateInit = initOf Item3(msg.id);
        let address: Address = contractAddress(init);
        send(SendParameters{
                to: address,
                value: 0,
                // когда будем с нашего deployer отправлять сообщение,
                // мы будем передавать какое-то кол-во TON,
                // и все эти TON coins пойдут дальше
                // и вот они-то и будут использоваться для того, чтобы наш контракт деплоил контракт
                // и комиссию за это платил пользователь, а не контракт-посредник
                mode: (SendRemainingValue + SendIgnoreErrors),
                bounce: true,
                code: init.code,
                data: init.data,
                // Если текст => asComment();
                // Если сообщение => toCell();
                body: Deploy{queryId: 0}.toCell()
            }
        );
    }

    get fun id(): Int {
        return self.id;
    }
}
