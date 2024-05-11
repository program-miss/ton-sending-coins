import "@stdlib/deploy";

contract SendTon with Deployable {
    const minTonForStorage: Int = ton("0.01"); // 1KB на 2,5 года
    owner: Address;
    init(){
        self.owner = sender();
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
        // если false => ошибка
        require(sender() == self.owner, "only owner is allowed to withdraw");
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
        require(sender() == self.owner, "only owner is allowed to withdraw");
        send(SendParameters{
                to: sender(),
                bounce: true,
                // все деньги на контракте - деньги, приходящие в сообщении - минимальное значение TON для аренды
                value: ((myBalance() - context().value) - self.minTonForStorage),
                mode: (SendIgnoreErrors + SendRemainingValue)
            }
        );
    }

    get fun balance(): Int {
        return myBalance();
    }
}
