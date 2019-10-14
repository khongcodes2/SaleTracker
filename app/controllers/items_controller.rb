class ItemsController < ApplicationController

########################################################################
#################             CREATE ACTION            #################
########################################################################

    get '/items/new' do
        current_user
        erb :'/items/new'
    end

    post '/items' do
        if params[:title].empty?||params[:author].empty?
            @error = "Please fill in required fields."
            erb :'/items/new'
        elsif !empty_or_valid_integer_or_float(params[:price])
            @error = "Please enter a valid price."
            erb :'/items/new'
        elsif !empty_or_valid_integer(params[:stock])
            @error = "Please enter a valid stock number."
            erb :'/items/new'
        else
            params[:price]=0 if params[:price].empty?
            params[:stock]=0 if params[:stock].empty?
            #parse params (price and stock) for input into Item.create
            input_hash = {
                :title => params[:title],
                :author => params[:author],
                :synopsis => params[:synopsis],
                :price => params[:price].to_f,
                :stock => params[:stock].to_i,
                :num_sold => 0,
                :image_url => params[:image_url],
            }
            item = Item.create(input_hash)
            current_user.items << item
            
            redirect "/items/#{item.id}"
        end
    end

########################################################################
#################              SHOW ACTION             #################
########################################################################

    get '/items/:id' do
        @item = Item.find_by(id:params[:id])
        erb :'/items/show'
    end

    get '/items/by/:slug' do
        @user = User.find_by_slug(params[:slug])
        @items = @user.items
        erb :'/items/slug_index'
    end

########################################################################
#################              EDIT ACTION             #################
########################################################################

    get '/items/:id/edit' do
        @item = Item.find_by(id:params[:id])
        if session[:user_id] != @item.user.id
            @error = "You don't have permission to make changes."
            erb :'/items/show'
        else
            erb :'/items/edit'
        end

    end

    patch '/items/:id/edit' do
        @item = Item.find_by(id:params[:id])

        #raise error if price, stock, or num_sold are not appropriate values
        if !empty_or_valid_integer_or_float(params[:price])
            @error = "Enter a valid price."
            erb :'/items/edit'
        elsif !empty_or_valid_integer(params[:stock])
            @error = "Enter a valid stock."
            erb :'/items/edit'
        elsif !empty_or_valid_integer(params[:num_sold])
            @error = "Enter a valid number sold."
            erb :'/items/edit'
        else
            #if blank do not change (case-by-case)
            @item.title = params[:title] unless params[:title].empty?
            @item.author = params[:author] unless params[:author].empty?
            @item.synopsis = params[:synopsis] unless params[:synopsis].empty?
            @item.price = params[:price].to_f unless params[:price].empty?
            @item.stock = params[:stock].to_i unless params[:stock].empty?
            @item.num_sold = params[:num_sold].to_i unless params[:num_sold].empty?
            @item.image_url = params[:image_url] unless params[:image_url].empty?
            @item.save
            redirect "/items/#{@item.id}"
        end
    end

    get '/items/sell' do
        current_user
        erb :'/items/sell'
    end

########################################################################
#################             DESTROY ACTION           #################
########################################################################

    delete '/items/:id' do
        item = Item.find_by(id:params[:id])
        item.delete
        redirect "/items/by/#{current_user.slug}"
    end

    helpers do
        def valid_integer(string)
            string.to_i.to_s==string
        end

        def valid_integer_or_float(string)
            /\A\d*\.\d{1,2}\z|\A\d+\z/ === string
        end

        def empty_or_valid_integer(string)
            string.empty? || valid_integer(string)
        end

        def empty_or_valid_integer_or_float(string)
            string.empty? || valid_integer_or_float(string)
        end

    end


end