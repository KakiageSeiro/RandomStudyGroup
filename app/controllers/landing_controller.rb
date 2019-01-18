class LandingController < ApplicationController

  require 'logger'

  def home

    log = Logger.new('/Users/yuta/RubymineProjects/RandomWiki/tmp/log')

    # APIからデータ取得
    # result = reqestRandom
    # テスト用ダミーデータ（スタイル違反はでる）
    array = {}
    array['events'] = [
        {
            'title'     => 'テストタイトル１'
        },
        {
            'title'     => 'テストタイトル２'
        },
        {
            'title'     => 'テストタイトル３'
        }
    ]
    result = array

    # タイトルのみ抽出
    titleMap = result['events'].map { |event|
      event['title']
    }

    # ブラウザで実行するとAPIからデータ取得できていない現象調査用ログ出力
    titleMap.map { |element|
      log.info('◇◇◇titleMap◇◇◇' + element + '◇◇◇')
    }

    # render :json => titleMap

    # Viewで利用するためにローカル変数に追加
    @renderTitleMap = titleMap

  end

  private

  require 'net/http'
  require 'net/https'
  require 'uri'
  require 'json'
  require 'logger'

  def reqestRandom

    # [クエリパラメータ]
    # URI.encode_www_formを使って「application/x-www-form-urlencoded」形式の文字列に変換
    # 文字列はURLエンコードされた形式に変換（半角スペースの"+"への変換等）
    #
    # （変換例）
    # 'bar baz' => 'bar+baz'
    # 'あ' => '%E3%81%82'
    # params = URI.encode_www_form(
    #     {
    #         format: 'json',
    #         action: 'query',
    #         list: 'random',
    #         rnnamespace: '0',
    #         rnlimit: '10'
    #     }
    # )
    params = URI.encode_www_form(
        {
            keyword: 'Java',

            # TODO:実行時の月から３ヶ月？ぐらいを自動で指定するように変更する
            ym: '201901' # イベント開催年月
        }
    )

    # [URI]
    # URI.parseは与えられたURIからURI::Genericのサブクラスのインスタンスを返す
    # -> 今回はHTTPプロトコルなのでURI::HTTPクラスのインスタンスが返される
    #
    # オブジェクトからは以下のようにして構成要素を取得できる
    # uri.scheme => 'http'
    # uri.host   => 'mogulla3.com'
    # uri.port   => 4567
    # uri.path   => ''
    # uri.query  => 'param1=foo&param2=bar+baz&param3=%E3%81%82'
    # uri = URI.parse("http://mogulla3.com:4567?#{params}")
    # httpUri = URI.parse("http://ja.wikipedia.org/w/api.php?#{params}")
    url = "connpass.com/api/v1/event/?"
    # url = "ja.wikipedia.org/w/api.php?"
    httpUri  = URI.parse("http://" + url + "#{params}")
    httpsUri = URI.parse("https://" + url + "#{params}")

    # httpリクエストを送信
    # result = doHttpReqest(httpUri)

    # httpsリクエストを送信
    result = doHttpsReqest(httpsUri)

    # # 301のエラーが返却された場合再実行
    # if result::code == '301'
    #   # リダイレクトが存在する場合
    #   if !result['Location'].nil?
    #
    #     # 前回実行したリクエスト結果に含まれるリダイレクト先を設定
    #     uri = URI.parse(result['Location'])
    #
    #     # TODO:ここでhttp or httpsの判定し、結果によって呼び出しメソッドを変更する
    #
    #     # リクエストを送信
    #     result = doHttpsReqest(uri)
    #
    #   else
    #     # httpsで再実行
    #     result = doHttpReqest(httpsUri)
    #   end
    # end
  end

  # # HTTPリクエスト送信処理
  # def doHttpReqest(uri)
  #   # [ロガー]
  #   # カレントディレクトリのwebapi.logというファイルに出力
  #   logger = Logger.new('./webapi.log')
  #
  #   begin
  #     # [GETリクエスト]
  #     # Net::HTTP.startでHTTPセッションを開始する
  #     # 既にセッションが開始している場合はIOErrorが発生
  #     response = Net::HTTP.start(uri.host, uri.port) do |http|
  #       # Net::HTTP.open_timeout=で接続時に待つ最大秒数の設定をする
  #       # タイムアウト時はTimeoutError例外が発生
  #       http.open_timeout = 5
  #
  #       # Net::HTTP.read_timeout=で読み込み1回でブロックして良い最大秒数の設定をする
  #       # デフォルトは60秒
  #       # タイムアウト時はTimeoutError例外が発生
  #       http.read_timeout = 10
  #
  #       # Net::HTTP#getでレスポンスの取得
  #       # 返り値はNet::HTTPResponseのインスタンス
  #       http.get(uri.request_uri)
  #     end
  #
  #     # [レスポンス処理]
  #     # 2xx系以外は失敗として終了することにする
  #     # ※ リダイレクト対応できると良いな..
  #     #
  #     # ステータスコードに応じてレスポンスのクラスが異なる
  #     # 1xx系 => Net::HTTPInformation
  #     # 2xx系 => Net::HTTPSuccess
  #     # 3xx系 => Net::HTTPRedirection
  #     # 4xx系 => Net::HTTPClientError
  #     # 5xx系 => Net::HTTPServerError
  #     case response
  #       # 2xx系
  #     when Net::HTTPSuccess
  #       # [JSONパース処理]
  #       # JSONオブジェクトをHashへパースする
  #       # JSON::ParserErrorが発生する可能性がある
  #       p JSON.parse(response.body)
  #
  #       # 3xx系
  #     when Net::HTTPRedirection
  #       # リダイレクト先のレスポンスを取得する際は
  #       # response['Location']でリダイレクト先のURLを取得してリトライする必要がある
  #       logger.warn("Redirection: code=#{response.code} message=#{response.message}")
  #       response
  #     else
  #       logger.error("HTTP ERROR: code=#{response.code} message=#{response.message}")
  #     end
  #
  #       # [エラーハンドリング]
  #       # 各種処理で発生しうるエラーのハンドリング処理
  #       # 各エラーごとにハンドリング処理が書けるようにrescue節は小さい単位で書く
  #       # (ここでは全て同じ処理しか書いていない)
  #   rescue IOError => e
  #     logger.error(e.message)
  #   rescue TimeoutError => e
  #     logger.error(e.message)
  #   rescue JSON::ParserError => e
  #     logger.error(e.message)
  #   rescue => e
  #     logger.error(e.message)
  #   end
  # end


  # HTTPSリクエスト送信処理
  def doHttpsReqest(uri)
    # [ロガー]
    # カレントディレクトリのwebapi.logというファイルに出力
    logger = Logger.new('./webapi.log')

    begin
      # [GETリクエスト]
      # Net::HTTP.startでHTTPセッションを開始する
      # 既にセッションが開始している場合はIOErrorが発生
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      response = http.start do |http|
        # Net::HTTP.open_timeout=で接続時に待つ最大秒数の設定をする
        # タイムアウト時はTimeoutError例外が発生
        http.open_timeout = 5

        # Net::HTTPS.read_timeout=で読み込み1回でブロックして良い最大秒数の設定をする
        # デフォルトは60秒
        # タイムアウト時はTimeoutError例外が発生
        http.read_timeout = 10

        # Net::HTTP#getでレスポンスの取得
        # 返り値はNet::HTTPResponseのインスタンス
        http.get(uri.request_uri)
      end

      # [レスポンス処理]
      # 2xx系以外は失敗として終了することにする
      # ※ リダイレクト対応できると良いな..
      #
      # ステータスコードに応じてレスポンスのクラスが異なる
      # 1xx系 => Net::HTTPInformation
      # 2xx系 => Net::HTTPSuccess
      # 3xx系 => Net::HTTPRedirection
      # 4xx系 => Net::HTTPClientError
      # 5xx系 => Net::HTTPServerError
      case response
        # 2xx系
      when Net::HTTPSuccess
        # [JSONパース処理]
        # JSONオブジェクトをHashへパースする
        # JSON::ParserErrorが発生する可能性がある
        json = JSON.parse(response.body)
        json

        # 3xx系
      when Net::HTTPRedirection
        # リダイレクト先のレスポンスを取得する際は
        # response['Location']でリダイレクト先のURLを取得してリトライする必要がある
        logger.warn("Redirection: code=#{response.code} message=#{response.message}")
        response
      else
        logger.error("HTTP ERROR: code=#{response.code} message=#{response.message}")
      end

        # [エラーハンドリング]
        # 各種処理で発生しうるエラーのハンドリング処理
        # 各エラーごとにハンドリング処理が書けるようにrescue節は小さい単位で書く
        # (ここでは全て同じ処理しか書いていない)
    rescue IOError => e
      logger.error(e.message)
    rescue TimeoutError => e
      logger.error(e.message)
    rescue JSON::ParserError => e
      logger.error(e.message)
    rescue => e
      logger.error(e.message)
    end
  end

end
