import "@stdlib/deploy";
message Withdraw {
    amount: Int as coins;
}

contract SendTon with Deployable {
    const minTonForStorage: Int = ton("0.01"); // 1KB на 2,5 года
    owner: Address;
    init(){
        self.owner = sender();
    }

     fun onlyOwner() {
        // если false => ошибка
        require(sender() == self.owner, "only owner is allowed to withdraw");
    }

    receive(){
        // Обучение
        // send(SendParameters{
        //         to: sender(),
        //         value: 0,
        //         // даже если в процессе отправки этого сообщения произойдет ошибка,
        //         // наш код не остановится, код продолжит дальше работать
        //         // не будет reject транзакции
        //         mode: SendIgnoreErrors,
        //         bounce: true,
        //         // asComment конвертирует строку в ячейку
        //         body: "Hello world".asComment()
        //     }
        // );
        // // можно send(SendParameters....) переписать вот так:
        // // но это только в случае, если мы хотим ответить sender()
        // self.reply("Hello world".asComment());
        // context().bounced; // true/false
        // context().sender; // sender()
        // context().value; // кол-во криптовалюты TON в сообщении
        // context().raw; // Slice
    }

    // Выводим все деньги с контракта и оставляем 0 баланс => нет денег для аренды => контракт будет удален
    receive("withdraw all"){
        self.onlyOwner();
        send(SendParameters{
                to: sender(),
                bounce: true,
                value: 0,
                // "SendIgnoreErrors" - В режиме отправки сообщения,
                // оно будет игнорировать ошибки
                // "SendRemainingBalance" - также отправляется весь текущий баланс на смарт-контракте в адрес "to"
                mode: (SendRemainingBalance + SendIgnoreErrors)
            }
        );
    }

    receive("withdraw safe"){
        self.onlyOwner();
        send(SendParameters{
                to: sender(),
                bounce: true,
                // все деньги на контракте - деньги, приходящие в сообщении - минимальное значение TON для аренды
                value: ((myBalance() - context().value) - self.minTonForStorage),
                mode: (SendIgnoreErrors + SendRemainingValue)
            }
        );
    }

    receive(msg: Withdraw){
        self.onlyOwner();
        // В случае, если баланс текущего смарт-контракта - отправленная сумма в сообщении (для комиссии) - минимальное значение для storage,
        // будет меньше, чем тот amount, который мы хотим вывести по итогу,
        // то мы не дадим вывести этот amount
        // мы выведем столько, сколько сможем себе позволить
        let amount: Int = min(msg.amount, ((myBalance() - context().value) - self.minTonForStorage));
        require(amount > 0, "Insufficient balance"); // недостаточный баланс
        send(SendParameters{
                to: sender(),
                bounce: true,
                value: amount,
                // Для того, чтобы не оставлять у себя деньги, которые не должны оставаться
                // Чтобы деньги, которые шли за комиссию, они оплатили комиссию и вернулись назад
                mode: (SendIgnoreErrors + SendRemainingValue)
            }
        );
    }

    get fun balance(): Int {
        return myBalance();
    }
}
