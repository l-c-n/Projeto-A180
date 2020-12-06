require_relative "routes/signup"
require_relative "libs/mongo_api"

describe "POST /signup" do
  # --equivalente a tela de cadastro do projeto WEB
  context "cadastrar novo usuario" do
    before(:all) do
      payload = { name: "Pedro", email: "pedro@gmail.com", password: "123" }
      MongoDB.new.remove_user(payload[:email])

      @result = Signup.new.create(payload)
    end
    # --valida se o resultado do cadastro foi 200OK
    it "validar status code" do
      expect(@result.code).to eql 200
    end
    # --valida se houve registro de Id do usuário no BD
    it "validar ID do usuário" do
      expect(@result.parsed_response["_id"].length).to eql 24
    end
  end

  # --valida se o usuário já existe em base
  context "usuario ja existe" do
    before(:all) do
      payload = { name: "Santiago", email: "santiago@gmail.com", password: "123" }
      MongoDB.new.remove_user(payload[:email])

      Signup.new.create(payload)
      @result = Signup.new.create(payload)
    end
    it "Deve retornar 409" do
      expect(@result.code).to eql 409
    end

    it "deve retornar mensagem email ja existente" do
      expect(@result.parsed_response["error"]).to eql "Email already exists :("
    end
  end

  # --Matriz de validação de tentativa de cadastro @cenários_Negativos
  exemples = [
    {
      tile: "nome obrigatorio",
      payload: { email: "santiago@gmail.com", password: "123" },
      code: 412,
      error: "required name",
    },
    {
      tile: "email obrigatorio",
      payload: { name: "Campos", password: "123" },
      code: 412,
      error: "required email",
    },
    {
      tile: "senha obrigatoria",
      payload: { name: "Campos", email: "campos@gmail.com" },
      code: 412,
      error: "required password",
    },
  ]

  exemples.each do |i|
    context "campos obrigatorios" do
      before(:all) do
        @result = Signup.new.create(i[:payload])
      end

      it "validar status code #{i[:code]}" do
        expect(@result.code).to eql i[:code]
      end
      it "validar resposta da API" do
        expect(@result.parsed_response["error"]).to eql i[:error]
      end
    end
  end
end
