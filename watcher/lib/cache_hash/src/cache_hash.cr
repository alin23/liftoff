class CacheHash(V)
  def initialize(@cache_time_span : Time::Span)
    @kv_hash = {} of String => V
    @time_hash = {} of String => Time
  end

  def get(key : String)
    if cached_time = @time_hash[key]?
      if cached_time > Time.local - @cache_time_span
        @kv_hash[key]
      else
        delete key
        nil
      end
    end
  end

  def set(key : String, val : V | Nil)
    if val.nil?
      delete key
    else
      @time_hash[key] = Time.local
      @kv_hash[key] = val
    end
  end

  private def delete(key : String) : String | Nil
    @time_hash.delete key
    @kv_hash.delete key
    nil
  end

  def purge_stale
    @kv_hash.select! do |k, v|
      if cached_time = @time_hash[k]?
        cached_time > Time.local - @cache_time_span
      end
    end
    nil
  end

  def keys
    purge_stale
    @kv_hash.keys
  end

  def fresh?(key : String)
    if cached_time = @time_hash[key]?
      if cached_time > Time.local - @cache_time_span
        true
      else
        delete key
        false
      end
    else
      false
    end
  end

  def time(key : String)
    if cached_time = @time_hash[key]?
      if cached_time > Time.local - @cache_time_span
        cached_time
      else
        delete key
      end
    end
  end

  def refresh(key : String)
    if cached_time = @time_hash[key]?
      if cached_time > Time.local - @cache_time_span
        @time_hash[key] = Time.local
        @kv_hash[key]
      else
        delete key
        nil
      end
    end
  end
end
